require 'fileutils'
require 'image_processing/vips'

module SrcsetImages
  class VipsCreateImageVersion

    # VipsCreateImageVersion.(source, destination, width: 800, height: 600, ...)
    def self.call(*_)
      new(*_).call
    end

    def initialize(img, destination_path, options = {})
      @source = if img.is_a?(String) || img.is_a?(Pathname)
                  ImageProcessing::Vips.source(img)
                else
                  img
                end

      @destination = destination_path

      @width  = options[:width]
      @height = options[:height]
      @crop   = !!options[:crop]

      @quality = options.fetch :quality, 90
    end


    def call
      img = if @crop
        @source.resize_to_fill @width, @height, crop: :attention
      else
        @source.resize_to_limit @width, @height
      end
      processed = img
        .saver(strip: true, quality: @quality, interlace: true)
        .call

      FileUtils.mkdir_p File.dirname(@destination)
      FileUtils.mv processed, @destination
      true
    end

  end
end

