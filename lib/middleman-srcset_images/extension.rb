require 'fileutils'
require 'middleman-core'
require 'middleman-srcset_images/view_helpers'

# Extension namespace
module SrcsetImages
  class Extension < ::Middleman::Extension

    helpers ViewHelpers

    attr_reader :images_dir, :sizes

    def initialize(app, options_hash={}, &block)
      # Call super to build options from the options_hash
      super

      # Require libraries only when activated
      require 'middleman-srcset_images/image'
      require 'middleman-srcset_images/html_converter'
      require 'middleman-srcset_images/srcset_config'

      # set up your extension
      # puts options.my_option

      @config = app.data['srcset_images'] || {}
      @sizes = @config['sizes'] || {}
      @source = Pathname('source')
      @images_dir = @source / (@config["images_dir"] || "images")
      @scaled_images_dir =  @source / (@config["destination_dir"] || "scaled_images")

      image_versions = @config['image_versions'] || {}
      @configurations = Hash[
        image_versions.map{ |name, config|
          [name.to_sym, SrcsetImages::SrcsetConfig.new(name, config)]
        }
      ]
      puts "Image versions: #{@configurations.keys.join ", "}"

      HtmlConverter.install
    end

    def after_configuration
    end

    # returns [path, srcset] for the given image, size and version name
    def srcset_config(image_path, size, version)
      img = SrcsetImages::Image.new image_path

      image_path = Pathname image_path
      rel_path = image_path.relative_path_from(@images_dir)
      rel_destdir = rel_path.parent
      destdir = @scaled_images_dir / rel_destdir

      config = @configurations[version.to_sym] || @configurations[img.orientation]

      default_path = nil
      srcset = config.image_versions(img).map do |filename, v|
        path = (destdir / filename).relative_path_from(@source)
        default_path = path if v["is_default"]
        [ path, v["width"] ]
      end
      default_path ||= image_path.relative_path_from(@source)
      srcset = srcset.map{|s| s.join " "}.join(", ")

      [default_path, srcset]
    end


    # helpers do
    #   def a_helper
    #   end
    # end
  end
end
