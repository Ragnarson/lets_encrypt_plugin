$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem"s version:
require "lets_encrypt_plugin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lets_encrypt_plugin"
  s.version     = LetsEncryptPlugin::VERSION
  s.authors     = ["Sebastian Wojtczak"]
  s.email       = ["wojtczaksebastian@gmail.com"]
  s.homepage    = "https://github.com/sabcio/lets_encrypt_plugin"
  s.summary     = "Summary of LetsEncryptPlugin."
  s.description = "Description of LetsEncryptPlugin."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4.2", "< 5.1"
  s.add_dependency "acme-client", "~> 0.5"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "fakeweb"
end
