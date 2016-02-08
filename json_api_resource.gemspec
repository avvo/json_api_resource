$:.push File.expand_path("../lib", __FILE__)

# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.

require 'json_api_resource/version'

Gem::Specification.new do |s|
  s.name = "json_api_resource"
  s.version = JsonApiResource::VERSION
  s.description = 'Wrapper Gem to extend the JsonApiClient::Resource'
  s.summary = 'Build wrapper/adapter objects around JsonApiClient instances'

  s.add_dependency "json_api_client", '~> 0.5'
  s.add_dependency "json_api_client_mock", '~> 0.2'
  s.add_dependency "activemodel"
  s.add_dependency "activesupport"
  
  s.add_development_dependency "webmock", '> 0'
  s.license = "MIT"

  s.author = "Brandon Sislow"
  s.email = "brandon.silsow@gmail.com"
  s.homepage = "https://github.com/avvo/json_api_resource"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir.glob('test/*_test.rb')
end
