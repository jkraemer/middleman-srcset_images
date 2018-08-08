# frozen_string_literal: true

module SrcsetImages
  module ViewHelpers

    # options can be:
    #
    # size: pick a srcset config from the :sizes hash
    #
    # version: pick an scaling set from the :image_versions hash. Defaults to
    # size, and if no such version is defined, will use landscape or portrait
    # depending on image orientation. In most cases you dont need to give this
    # option.
    #
    # link: Set to an url to link to
    #
    def image_tag(path, options = {})
      ext = app.extensions[:srcset_images]

      # allow for images in article directories to be referenced just by file name
      unless path[?/]
        # posts/2016/....html.md
        page_path = current_page.file_descriptor.relative_path
        # source/images/posts/2016/...
        dir = ext.images_dir / File.dirname(page_path)
        # source/images/posts/2016/.../foo.jpg
        path = File.join dir, File.basename(page_path, '.html.md'), path
        rel_path = path
      else
        rel_path = Pathname("source") / path.sub(/\A\/?/, "")
      end

      # collect srcset info
      options = options.dup

      if File.readable?(rel_path) and size = options.delete(:size)
        version_name = (options.delete(:version) || size).to_s
        options[:sizes] = ext.sizes[size]

        path, srcset = ext.srcset_config(rel_path, size, version_name)

        options[:srcset] = srcset
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

