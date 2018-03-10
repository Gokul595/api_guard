$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rabbit_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rabbit_api"
  s.version     = RabbitApi::VERSION
  s.authors     = ['Gokul Murali']
  s.email       = ['m.gokul595@gmail.com']
  s.homepage    = "https://github.com/Gokul595/rabbit_api"
  s.summary     = "Building Rails API made easy"
  s.description = "Build easy and quick Rails API with JWT authentication and pagination"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.5"
  s.add_dependency 'jwt', '~> 2.1.0'
  s.add_dependency 'active_model_serializers', '~> 0.10.0'
end
