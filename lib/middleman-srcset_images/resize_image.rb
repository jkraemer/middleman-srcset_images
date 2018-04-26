require 'middleman-srcset_images/create_image_version'

module SrcsetImages
  # FIXME unused?
  class ResizeImage

    def self.call(image)
      puts image.path
      new(image).call
    end

    def initialize(image)
      @image = image
      @path = image.path
      @config = image.config

      @crop    = @config.fetch :crop, false
      @quality = @config.fetch :quality, 80
      @gravity = @config.fetch :gravity, 'Center'
      @ratio   = @config.fetch :ratio, image.xy_ratio
    end

    def call
      @image.sizes.map do |path, size_config|
        path if create_version(path, size_config)
      end.compact
    end

    private

    def create_version(path, config)
      width   = config.width
      height  = config.height
      if width.nil? && height.nil?
        raise ArgumentError, "need at least width or height!\nconfig was: #{config}"
      end

      ratio   = config.fetch :ratio, @ratio

      if width.blank?
        width = (height.to_f * ratio).to_i
      end
      if height.blank?
        height = (width.to_f / ratio).to_i
      end

      CreateImageVersion.(
        @image.path, path,
        width: width,
        height: height,
        quality: config.fetch(:quality, @quality),
        gravity: config.fetch(:gravity, @gravity),
        ratio: ratio,
        crop: config.fetch(:crop, @crop)
      )
    end

  end
end

