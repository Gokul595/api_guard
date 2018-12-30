$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api_guard/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api_guard"
  s.version     = ApiGuard::VERSION
  s.authors     = ['Gokul Murali']
  s.email       = ['m.gokul595@gmail.com']
  s.homepage    = "https://github.com/Gokul595/api_guard"
  s.summary     = "Rails API authentication made easy"
  s.description = "Authentication solution for Rails API with JWT"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'jwt', '~> 2.1.0'
  s.add_dependency 'active_model_serializers', '~> 0.10.0'

  s.add_development_dependency "rails", "~> 5.1.5"
  s.add_development_dependency 'sqlite3', '~> 1.3.13'
  s.add_development_dependency 'bcrypt', '~> 3.1.11'
  s.add_development_dependency 'rspec-rails', '~> 3.7.2'
  s.add_development_dependency 'factory_bot_rails', '~> 4.8.2'
  s.add_development_dependency 'simplecov', '~> 0.16.1'
end
