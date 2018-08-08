module SrcsetImages
  class SrcsetConfig
    attr_reader :name, :config

    def initialize(name, config)
      @name = name
      @config = config

      @base_config = {
        "name" => name,
        "crop" => config.fetch("crop", false),
        "quality" => config.fetch("quality", 80),
      }
    end

    def image_versions(img)
      result = {}

      if applies_to?(img)
        @config["srcset"].each_with_index do |config, idx|
          result[img.name_for_version(@name, idx)] =
            @base_config.merge(config)
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
