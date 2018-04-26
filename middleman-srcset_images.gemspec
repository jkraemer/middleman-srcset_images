# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman-srcset_images"
  s.version     = "0.2.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jens Kraemer"]
  s.email       = ["jk@jkraemer.net"]
  s.homepage    = "https://github.com/jkraemer/middleman-srcset_images"
  s.summary     = %q{Responsive images for Middleman}
  s.description = %q{Middleman plugin for automatic img tags with proper srcset attributes. You can configure any number of image size sets for different use cases (i.e. different image sizes for teasers, portrait and landscape images). Scaled images are generated using libvips.}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  # The version of middleman-core your extension depends on
  s.add_runtime_dependency("middleman-core", ["~> 4.2"])

  # Additional dependencies
  s.add_runtime_dependency("dimensions", ["~> 1.3"])
  s.add_runtime_dependency("image_processing", ["~> 1.0"])
  s.add_runtime_dependency("ruby-vips", ["~> 2.0"])
end
