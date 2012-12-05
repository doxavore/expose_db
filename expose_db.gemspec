require File.expand_path("../lib/expose_db/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "expose_db"
  s.rubyforge_project = s.name
  s.version     = ExposeDB.version
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Expose your database over an API."
  s.description = s.summary
  s.author      = "Doug Mayer"
  s.email       = "doxavore@gmail.com"
  s.homepage    = "https://github.com/doxavore/expose_db"
  s.license     = "MIT"
  s.files       = %w(MIT-LICENSE README.md) + Dir["{bin,spec,lib}/**/*"]
  s.require_path = "lib"
  s.bindir      = "bin"
  s.executables << "expose-db"
  s.required_ruby_version = ">= 1.9.1"

  s.add_dependency 'sinatra'
  s.add_dependency 'sequel'
  s.add_dependency 'multi_json'
end
