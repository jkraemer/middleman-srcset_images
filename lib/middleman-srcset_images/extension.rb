require 'fileutils'
require 'middleman-core'
require 'middleman-srcset_images/view_helpers'

# Extension namespace
module SrcsetImages
  class Extension < ::Middleman::Extension

    option :cache_dir, 'tmp/srcset_images-cache', 'Directory (relative to project root) for cached image versions.'

    helpers ViewHelpers

    attr_reader :image_versions, :scaled_images, :sizes

    def initialize(app, options_hash={}, &block)
      # Call super to build options from the options_hash
      super

      # Require libraries only when activated
      require 'middleman-srcset_images/img'
      require 'middleman-srcset_images/version_resource'
      require 'middleman-srcset_images/html_converter'
      require 'middleman-srcset_images/srcset_config'

      # set up your extension
      # puts options.my_option

      @config = app.data['srcset_images'] || {}
      @image_versions = @config['image_versions'] || {}
      @images = @config['images']
      @sizes = @config['sizes'] || {}
      @scaled_images = Hash.new{|h,k| h[k] = []}

      puts "Image versions: #{image_versions.keys.join ", "}"

      HtmlConverter.install
    end

    def after_configuration
      FileUtils.mkdir_p options.cache_dir
    end

    def manipulate_resource_list(resources)
      basedir = File.absolute_path(File.join(app.root, app.config[:source]))
      Dir.chdir(basedir) do
        versions = []
        cache_dir = File.absolute_path(options.cache_dir, app.root)

        configurations = image_versions.map do |name, config|
          SrcsetImages::SrcsetConfig.new name, config, cache_dir: cache_dir
        end

        images = Dir.glob(@images).map{|f| SrcsetImages::Img.new(f)}

        # loop over configurations for landscape, portrait, teasers
        configurations.each do |config|

          #loop over original image files
          images.each do |img|

            # loop over different image sizes of configuration
            config.image_versions(img).each do |v|
              v.app = app
              v.prepare_image
              @scaled_images[img.path] << v
              versions << VersionResource.new(app.sitemap, v)
            end

          end
        end
        versions.flatten!
        versions.compact!
        puts "added #{versions.size} image versions"
        resources + versions
      end
    end

    # helpers do
    #   def a_helper
    #   end
    # end
  end
end
