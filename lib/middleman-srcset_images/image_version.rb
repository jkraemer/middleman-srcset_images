module SrcsetImages
  class ImageVersion

    attr_reader :img_path, :resized_img_path, :config, :name, :width

    # resized_img_path is the wrong path here
    # (posts/2013/08-17-kilimanjaro/bay_ls_0.jpg instead of
    # 2013/08/kilimanjaro/bay_ls_0.jpg)
    # but it does not seem to matter since this is apparently fixed by
    # middleman itself through the VersionResource
    def initialize(app, img_path, resized_img_path, config)
      @middleman_config = app.config
      @app = app

      @img_path = img_path
      @resized_img_path = resized_img_path

      @config = config

      @name    = config[:name]
      @default = !!config[:is_default]
      @width   = config[:width]
      @height  = config[:height]

      if @width.nil? && @height.nil?
        raise ArgumentError, "need at least width or height!\nconfig was: #{config}"
      end

      @ratio   = config[:ratio]
      @original_orientation = config[:original_orientation]

      @crop    = config.fetch :crop, false
      @quality = config.fetch :quality, 80
      @gravity = config.fetch :gravity, 'Center'

      @tmp_dir = config[:tmp_dir]
    end

    def default?
      @default
    end

    def default_for_orientation?
      @name == @original_orientation
    end

    def base64_data
      prepare_image
      Base64.strict_encode64(File.read(cached_resized_img_abs_path))
    end

    def render
      prepare_image
      File.read(cached_resized_img_abs_path)
    end

    def image_checksum
      @image_checksum ||= Digest::SHA2.file(abs_path).hexdigest[0..16]
    end

    def image_name
      File.basename(abs_path)
    end

    def abs_path
      File.join(source_dir, @img_path)
    end

    def middleman_resized_abs_path
      middleman_abs_path.gsub(image_name, resized_image_name)
    end

    def middleman_abs_path
      img_path.start_with?('/') ? img_path : File.join(images_dir, img_path)
    end

    def cached_resized_img_abs_path
      File.join(cache_dir, resized_img_path).split('.').tap { |a|
        a.insert(-2, image_checksum)
      }.join('.')
    end

    def prepare_image
      unless cached_image_available?
        save_cached_image
      end
    end

    private

    def source_dir
      File.absolute_path(@middleman_config[:source], @app.root)
    end

    def images_dir
      @middleman_config[:images_dir]
    end

    def build_dir
      @middleman_config[:build_dir]
    end

    def cache_dir
      File.absolute_path(@tmp_dir, @app.root)
    end

    def save_cached_image
      if @width.blank?
        @width = (@height.to_f * @ratio).to_i
      end
      if @height.blank?
        @height = (@width.to_f / @ratio).to_i
      end

      FileUtils.mkdir_p(File.dirname(cached_resized_img_abs_path))
      CreateImageVersion.(
        @img_path, cached_resized_img_abs_path,
        width: @width, height: @height,
        quality: @quality, gravity: @gravity, ratio: @ratio, crop: @crop
      )
    end

    def cached_image_available?
      File.exist?(cached_resized_img_abs_path)
    end

  end
end


