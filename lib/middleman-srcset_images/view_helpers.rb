# frozen_string_literal: true

module SrcsetImages
  module ViewHelpers

    def image_tag(path, options = {})
      # allow for images in article directories to be referenced just by file name
      unless path[?/]
        page_path = current_page.path
        dir = File.dirname page_path
        path = File.join dir, File.basename(page_path, '.html'), path
      end

      # collect srcset info
      options = options.dup
      ext = app.extensions[:srcset_images]
      versions = ext.image_versions
      rel_path = path.sub(/\A\/?/, "")

      if size = options.delete(:size) and
          (versions = ext.scaled_images[rel_path].select{|v|v.name == size.to_s}).any?

        default = versions.detect{|v|v.default?} || versions.first

        options[:srcset] = versions.map { |v|
          "#{v.resized_img_path} #{v.width}w"
        }.join ", "
        super default.resized_img_path, options
      else
        super
      end
    end

  end
end


