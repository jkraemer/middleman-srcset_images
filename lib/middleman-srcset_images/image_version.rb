#require 'middleman-srcset_images/create_image_version'
require 'middleman-srcset_images/vips_create_image_version'

module SrcsetImages
  class ImageVersion

    attr_reader :img, :resized_img_path, :config, :name, :width
    attr_accessor :app

    # resized_img_path is the wrong path here
    # (posts/2013/08-17-kilimanjaro/bay_ls_0.jpg instead of
    # 2013/08/kilimanjaro/bay_ls_0.jpg)
    # but it does not seem to matter since this is apparently fixed by
    # middleman itself through the VersionResource
    def initialize(img, resized_img_path, config)
      @img = img
      @resized_img_path = resized_img_path
      @config = config

      @default_for_orientation = config[:name] == img.orientation

      @width   = config[:width]
      @height  = config[:height]

      if @width.nil? && @height.nil?
        raise ArgumentError, "need at least width or height!\nconfig was: #{config}"
      end

      ratio = config[:ratio] || img.xy_ratio
      if @width.blank?
        @width = (@height.to_f * ratio).to_i
      end
      if @height.blank?
        @height = (@width.to_f / ratio).to_i
      end

      @crop    = config.fetch :crop, false
      @quality = config.fetch :quality, 80
      @cache_dir = config[:cache_dir]
    end


    def img_path
      img.rel_path
    end

    def default?
      !!config[:is_default]
    end

    def default_for_orientation?
      @default_for_orientation
    end

    def base64_data
      Base64.strict_encode64 render
    end

    def render
      prepare_image
      File.read cached_resized_img_abs_path
    end


    #def middleman_resized_abs_path
    # #middleman_abs_path.gsub(img.filename, resized_image_name)
    #  File.join File.dirname(img.abs_path), resized_image_name
    #end

    #def middleman_abs_path
    #  img_path.start_with?('/') ? img_path : File.join(images_dir, img_path)
    #end

    def cached_resized_img_abs_path
      File.join(@cache_dir, resized_img_path).split('.').tap { |a|
        a.insert(-2, img.checksum)
      }.join('.')
    end

    def prepare_image
      unless cached_image_available?
        save_cached_image
      end
    end

    private

    def source_dir
      File.absolute_path(app.config[:source], @app.root)
    end

    def images_dir
      app.config[:images_dir]
    end

    def build_dir
      app.config[:build_dir]
    end

    def save_cached_image
      FileUtils.mkdir_p(File.dirname(cached_resized_img_abs_path))
      VipsCreateImageVersion.(
        img.vips, cached_resized_img_abs_path,
        width: @width, height: @height, quality: @quality, crop: @crop
      )
    end

    def cached_image_available?
      File.readable?(cached_resized_img_abs_path)
    end

  end
end


