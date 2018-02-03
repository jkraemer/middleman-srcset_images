# frozen_string_literal: true

require 'middleman-core/renderers/kramdown'

module SrcsetImages
  module HtmlConverter

    def self.install
      unless Middleman::Renderers::MiddlemanKramdownHTML < self
        Middleman::Renderers::MiddlemanKramdownHTML.prepend self
      end
    end

    def convert_img(el, indent)
      attrs = el.attr.dup

      attrs['title'] ||= attrs['alt']

      src = attrs.delete "src"

      path, size, link_to = src.split(?!)
      # default to jpg as image file extension
      path += ".jpg" unless path =~ /\.[a-z]{3}\z/i

      if link_to
        attrs[:link] = link_to
      end

      if size
        attrs[:size] = size

        %{<div class="item #{size}">} + scope.image_tag(path, attrs) + "</div>"
      else
        scope.image_tag path, attrs
      end
    end

  end
end

