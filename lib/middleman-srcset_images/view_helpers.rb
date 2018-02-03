# frozen_string_literal: true

module SrcsetImages
  module ViewHelpers

    # options can be:
    #
    # size: pick an image version
    # link: Set to an url to link to
    #
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
      rel_path = path.sub(/\A\/?/, "")
      versions = nil

      if size = options.delete(:size)
        options[:sizes] = ext.sizes[size]

        scaled_images = ext.scaled_images[rel_path]
        versions = scaled_images.select{|v| v.name == size.to_s}
        unless versions.any?
          versions = scaled_images.select{|v| v.default_for_orientation?}
        end

        if versions.any?
          path = (versions.detect{|v|v.default?} || versions.first).resized_img_path
          options[:srcset] = versions.map { |v|
            "#{v.resized_img_path} #{v.width}w"
          }.join ", "
        end
      end

      link = options.delete(:link)
      img = super path, options

      if link
        link_to img, link
      else
        img
      end
    end

  end
end

