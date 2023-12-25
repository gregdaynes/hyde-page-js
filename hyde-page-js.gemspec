require File.expand_path("../lib/hyde-page-js.rb", __FILE__)

Gem::Specification.new do |s|
  s.name = "hyde-page-js"
  s.version = Hyde::Page::Js::VERSION
  s.summary = "Plugin for jekyll to enable per page js files"
  s.description = "Hyde Page JS is a plugin for Jekyll that enables concatenating, processing and caching js files for separate pages."
  s.authors = ["Gregory Daynes"]
  s.email = "email@gregdaynes.com"
  s.homepage = "https://github.com/gregdaynes/hyde-page-js"
  s.license = "MIT"

  s.files = Dir["{lib}/**/*.rb"]
  s.require_path = "lib"

  s.add_development_dependency "jekyll", ">= 4.0", "< 5.0"
  s.add_development_dependency "terser", "~> 1.1"
end
