require 'dimensions'
require 'image_processing/vips'
require 'middleman-srcset_images/dimensions_patch'

module SrcsetImages
  class Img

    attr_reader :path, :abs_path, :width, :height

    def initialize(path)
      @path = path
      @abs_path = Pathname(path).absolute? ? path : File.join(Dir.pwd, path)
    end

    def orientation
      landscape? ? 'landscape' : 'portrait'
    end

    def rel_path
      @rel_path ||= Pathname(abs_path).relative_path_from(Pathname(Dir.pwd))
    end

    # true if landscape or square
    def landscape?
      xy_ratio >= 1
    end

    # true if portrait
    def portrait?
      xy_ratio < 1
    end

    def vips
      @vips ||= ImageProcessing::Vips.source(abs_path)
    end

    def path_for_version(cfg_name, idx)
      "#{File.dirname rel_path}/#{basename}_#{cfg_name}_#{idx}#{ext}"
    end

    def basename
      @basename ||= File.basename path, ext
    end

    def filename
      File.basename path
    end

    def ext
      @ext ||= File.extname path
    end

    def checksum
      @checksum ||= Digest::SHA2.file(abs_path).hexdigest[0..16]
    end

    # TODO can get dimensions from vips?
    def xy_ratio
      @xy_ratio ||= begin
        File.open(abs_path, 'rb') do |io|
          Dimensions(io)
          io.extend DimensionsPatch
          @width, @height = io.dimensions
          @width.to_f / @height
        end
      end
    rescue
      nil
    end

  end
end


