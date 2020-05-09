require 'fileutils'
require 'image_processing/vips'

module SrcsetImages
  class VipsCreateImageVersion

    # VipsCreateImageVersion.(source, destination, width: 800, height: 600, ...)
    def self.call(*_)
      new(*_).call
    end

    # width: required
    # height: required
    # quality: 90,
    # crop: false,
    # watermark: {
    #   path: required,
    #   width_percent: 10,
    #   gravity: 'south-west',
    #   offset: [1,1]
    # }
    # offset is given in percent of the respective base image dimension
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
      if @watermark = options.fetch(:watermark)
        @watermark = { path: @watermark } if @watermark.is_a?(String) || @watermark.is_a?(Pathname)
        @watermark.symbolize_keys!
      end
    end

    # returns the path to a properly scaled watermark or nil if no watermark configured
    def watermark
      return nil unless @watermark
      percent_width = @watermark.fetch(:width_percent, 10).to_i
      file = @watermark[:path]
      fail "cannot read watermark #{file}" unless File.readable?(file)
      wm_dir = File.dirname file
      wm_ext = File.extname file
      wm_name = File.basename file, wm_ext

      wm_width = (@width * percent_width / 100).to_i
      scaled_watermark = File.join wm_dir, "#{wm_name}_#{wm_width}#{wm_ext}"
      unless File.readable?(scaled_watermark)
        scaled = ImageProcessing::Vips.
          source(file).
          resize_to_limit(wm_width, @height).
          saver(strip: true, quality: 100, interlace: false).
          call
        FileUtils.mv scaled, scaled_watermark
      end
      scaled_watermark
    end


    def call
      img = if @crop
        @source.resize_to_fill @width, @height, crop: :centre
      else
        @source.resize_to_limit @width, @height
      end
      if wm = watermark
        x_off, y_off = @watermark.fetch :offset, [0,0]
        if x_off.to_s.end_with? '%'
          x_off = x_off.to_f * @width / 100
        end
        if y_off.to_s.end_with? '%'
          y_off = y_off.to_f * (@height||@width) / 100
        end

        img = img.composite wm,
          gravity: @watermark.fetch(:gravity, 'south-west'),
          offset: [x_off, y_off].map(&:to_i)
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

