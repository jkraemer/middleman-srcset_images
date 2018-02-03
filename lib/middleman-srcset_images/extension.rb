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
      require 'middleman-srcset_images/image'
      require 'middleman-srcset_images/resize_image'
      require 'middleman-srcset_images/version_resource'
      require 'middleman-srcset_images/html_converter'

      # set up your extension
      # puts options.my_option

      @config = app.data['srcset_images'] || {}
      @image_versions = @config['image_versions'] || {}
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
        image_versions.each do |name, config|
          Dir.glob(config.images) do |image_file|
            img = Image.new image_file, app, name, config.merge(tmp_dir: options.cache_dir)
            img.image_versions.each do |v|
              v.prepare_image
              @scaled_images[image_file] << v
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
