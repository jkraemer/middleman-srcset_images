require 'dimensions'
require 'image_processing/vips'
require 'middleman-srcset_images/dimensions_patch'

module SrcsetImages
  class Image
    attr_reader :xy_ratio

    def initialize(path)
      @path     = path
      @ext      = File.extname path
      @basename = File.basename path, @ext
    end

    def xy_ratio
      @xy_ratio ||= File.open(@path, 'rb') do |io|
        Dimensions(io)
        io.extend SrcsetImages::DimensionsPatch
        width, height = io.dimensions
        width.to_f / height
      end
    end

    def mtime
      @mtime ||= File.mtime @path
    end

    def name_for_version(cfg_name, idx)
      "#{@basename}_#{cfg_name}_#{idx}#{@ext}"
    end

    def orientation
      landscape? ? :landscape : :portrait
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
      @vips ||= ImageProcessing::Vips.source(@path)
    end
  end
end


