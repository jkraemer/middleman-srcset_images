# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman-srcset_images"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jens Kraemer"]
  s.email       = ["jk@jkraemer.net"]
  # s.homepage    = "http://example.com"
  s.summary     = %q{Responsive images for Middleman}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # The version of middleman-core your extension depends on
  s.add_runtime_dependency("middleman-core", [">= 4.2.1"])

  # Additional dependencies
  s.add_runtime_dependency("mini_magick", [">= 4.8.0"])
  s.add_runtime_dependency("dimensions", [">= 1.3.0"])
end
