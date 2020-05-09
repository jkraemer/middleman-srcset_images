# frozen_string_literal: true

require "dimensions"
require "fileutils"
require "pathname"

require "middleman-srcset_images/image"
require "middleman-srcset_images/srcset_config"
require "middleman-srcset_images/vips_create_image_version"

module SrcsetImages
  class CreateImageVersions
    def initialize(base_dir: ".", config: "data/srcset_images.yml")
      @base_dir = Pathname(base_dir)
      @source = @base_dir / "source"

      fail "no source directory in #{dir}" unless File.directory? @source

      config = @base_dir / config
      fail "cannot read config #{config}" unless File.readable? config

      config = YAML.load IO.read config

      @image_versions = config["image_versions"] || {}
      @images_dir         = @source / (config["images_dir"] || "images")
      @images = @images_dir / (config["images_glob"] || "/**/*.jpg")

      @sizes          = config["sizes"] || {}
      @destination = @source / (config["destination_dir"] || "scaled_images")
    end

    def self.call(*_)
      new(*_).call
    end

    def call
      FileUtils.mkdir_p @destination

      @configurations = @image_versions.map do |name, config|
        SrcsetConfig.new name, config
      end

      Dir.glob(@images).each{|f| process_image f}
    end

    private


    def process_image(path)
      # do not process already scaled images
      return if path.start_with? @destination.to_s

      puts path

      rel_path = Pathname(path).relative_path_from(@images_dir)
      rel_destdir = rel_path.parent
      destdir = @destination / rel_destdir
      FileUtils.mkdir_p destdir

      img = Image.new(path)

      @configurations.each do |config|
        next unless config.applies_to? img

        config.image_versions(img).each do |filename, v|
          dest_file = destdir / filename
          next if File.exist?(dest_file) && File.mtime(dest_file) > img.mtime

          puts dest_file
          SrcsetImages::VipsCreateImageVersion.(
            img.vips, dest_file,
            width: v["width"], height: v["height"],
            quality: v["quality"], crop: v["crop"],
            watermark: v["watermark"]
          )
        end

      end

    end

  end
end
