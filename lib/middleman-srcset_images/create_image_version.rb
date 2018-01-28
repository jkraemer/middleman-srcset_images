require 'fileutils'
require 'mini_magick'

module SrcsetImages
  class CreateImageVersion

    # CreateImageVersion.(source, destination, width: 800, height: 600, ...)
    def self.call(*_)
      new(*_).call
    end

    def initialize(source_path, destination_path, options = {})
      @source = source_path
      @destination = destination_path

      @width  = options[:width]
      @height = options[:height]
      @crop   = !!options[:crop]

      @gravity = options.fetch :gravity, 'Center'
      @quality = options.fetch :quality, 90
      @ratio   = options.fetch :ratio, 1
    end


    def call
      FileUtils.mkdir_p File.dirname(@destination)
      image = MiniMagick::Image.open(@source)
      if @crop
        crop image
      else
        resize image
      end
      image.write @destination
      true
    end

    private

    def resize(img)
      img.combine_options do |cmd|
        cmd.resize "#{@width}x#{@height}>"
        trim_down cmd
      end
    end

    def crop(img)
      cols, rows = img[:dimensions]

      img.combine_options do |cmd|
        if @width != cols || @height != rows
          scale_x = @width/cols.to_f
          scale_y = @height/rows.to_f
          if scale_x >= scale_y
            cols = (scale_x * (cols + 0.5)).round
            rows = (scale_x * (rows + 0.5)).round
            cmd.resize "#{cols}"
          else
            cols = (scale_y * (cols + 0.5)).round
            rows = (scale_y * (rows + 0.5)).round
            cmd.resize "x#{rows}"
          end
        end
        cmd.gravity @gravity
        cmd.background "rgba(255,255,255,0.0)"
        cmd.extent "#{@width}x#{@height}" if cols != @width || rows != @height
        trim_down cmd
      end
    end

    def trim_down(cmd)
      cmd.strip
      cmd.quality @quality
      cmd.depth "8"
      cmd.interlace "plane"
    end

  end
end
