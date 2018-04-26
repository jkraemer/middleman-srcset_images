require 'middleman-srcset_images/image_version'

module SrcsetImages
  class SrcsetConfig

    attr_reader :name, :config

    def initialize(name, config, cache_dir:)
      @name = name
      @config = config

      @base_config = {
        name: name,
        crop: config.fetch(:crop, false),
        quality: config.fetch(:quality, 80),
        cache_dir: cache_dir
      }
    end

    def image_versions(img)
      result = []

      if applies_to?(img)


        config.srcset.each_with_index do |config, idx|
          result << ImageVersion.new(
            img,
            img.path_for_version(name, idx),
            @base_config.merge(config.symbolize_keys)
          )
        end
      end

      result
    end

    def applies_to?(img)
      not ((name == 'landscape' && img.portrait?) or
           (name == 'portrait' && img.landscape?))
    end

  end
end
