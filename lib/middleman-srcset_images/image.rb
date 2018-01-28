require 'tempfile'
require 'dimensions'
require 'middleman-srcset_images/dimensions_patch'
require 'middleman-srcset_images/image_version'

module SrcsetImages
  class Image

    attr_reader :path, :config, :abs_path

    def initialize(path, app, config_name, config)
      @path = path
      @config_name = config_name
      @config = config
      @app = app

      @abs_path = Pathname(path).absolute? ? path : File.join(Dir.pwd, path)

      @base_config = {
        name: config_name,
        crop: config.fetch(:crop, false),
        quality: config.fetch(:quality, 80),
        gravity: config.fetch(:gravity, 'Center'),
        ratio: config.fetch(:ratio, xy_ratio),
        tmp_dir: config.tmp_dir
      }
    end

    def image_versions()
      @image_versions ||= [].tap do |arr|
        @config.srcset.each_with_index { |config, idx|
          arr << ImageVersion.new(
            @app, @path, version_path(extension: idx),
            @base_config.merge(config.symbolize_keys)
          )
        }
      end
    end

    def default_path
      size = sizes.detect{ |path, config| config.is_default }
      size[0]
    end

    private

    def xy_ratio
      @xy_ratio ||= begin
        File.open(@path, 'rb') do |io|
          Dimensions(io)
          io.extend DimensionsPatch
          width, height = io.dimensions
          width.to_f / height
        end
      end
    rescue
      nil
    end

    def base_path
      @base_path ||= version_path extension: @config_name, path: @path
    end

    # version_name('ls')
    # => 'foo_ls.jpg'
    def version_path(path: base_path, extension:)
      ext = File.extname path
      "#{File.dirname path}/#{File.basename path, ext}_#{extension}#{ext}"
    end
  end
end

