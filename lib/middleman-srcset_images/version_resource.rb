module SrcsetImages
  class VersionResource < ::Middleman::Sitemap::Resource
    def initialize(store, image_version)
      super store, image_version.resized_img_path, image_version.cached_resized_img_abs_path
    end

    def ignored?
      false
    end

    def template?
      false
    end

    def binary?
      true
    end
  end
end

