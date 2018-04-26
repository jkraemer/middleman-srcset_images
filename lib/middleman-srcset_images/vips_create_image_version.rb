require 'fileutils'
require 'image_processing/vips'

module SrcsetImages
  class VipsCreateImageVersion

    # VipsCreateImageVersion.(source, destination, width: 800, height: 600, ...)
    def self.call(*_)
      new(*_).call
    end

    def initialize(source_path, destination_path, options = {})
      @source = source_path
      @destination = destination_path

      @width  = options[:width]
      @height = options[:height]
      @crop   = !!options[:crop]

      @quality = options.fetch :quality, 90
    end


    def call
      img = ImageProcessing::Vips.source(@source)
      if @crop
        img.resize_to_fill @width, @height, crop: :attention
      else
        img.resize_to_limit @width, @height
      end
      processed = img.saver(strip: true, quality: @quality).call

      FileUtils.mkdir_p File.dirname(@destination)
      FileUtils.mv processed, @destination
      true
    end

  end
end

