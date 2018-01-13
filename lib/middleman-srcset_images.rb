require "middleman-core"

Middleman::Extensions.register :srcset_images do
  require "middleman-srcset_images/extension"
  SrcsetImagesExtension
end
