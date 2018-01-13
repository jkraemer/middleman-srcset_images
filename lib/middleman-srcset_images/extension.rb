# Require core library
require 'middleman-core'

# Extension namespace
class SrcsetImagesExtension < ::Middleman::Extension

  option :cache_dir, 'tmp/srcset_images-cache', 'Directory (relative to project root) for cached image versions.'

  attr_reader :image_versions

  def initialize(app, options_hash={}, &block)
    # Call super to build options from the options_hash
    super

    # Require libraries only when activated
    # require 'necessary/library'

    # set up your extension
    # puts options.my_option

    @config = app.data['srcset_images'] || {}
    @image_versions = config['image_versions']
    puts "Image versions: #{@image_versions.keys.join ", "}"
  end

  def after_configuration
    # Do something
  end

  def manipulate_resource_list(resources)
    Dir.chdir(File.absolute_path(File.join(app.root, app.config[:source]))) do
      resources + image_versions.map do |name, config|
        Dir.glob(config.path) do |image_file|
          puts image_file
        end
      end
    end
  end

  # helpers do
  #   def a_helper
  #   end
  # end
end
