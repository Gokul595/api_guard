# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'api_guard/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'api_guard'
  s.version     = ApiGuard::VERSION
  s.authors     = ['Gokul Murali']
  s.email       = ['m.gokul595@gmail.com']
  s.homepage    = 'https://github.com/Gokul595/api_guard'
  s.summary     = 'Rails API authentication made easy'
  s.description = 'JWT authentication solution for Rails APIs'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'jwt', '~> 2.1', '>= 2.1.0'

  s.add_development_dependency 'bcrypt', '~> 3.1', '>= 3.1.11'
  s.add_development_dependency 'factory_bot_rails', '~> 4.8', '>= 4.8.2'
  s.add_development_dependency 'rails', '~> 5.1', '>= 5.1.5'
  s.add_development_dependency 'rspec-rails', '~> 3.7', '>= 3.7.2'
  s.add_development_dependency 'rubocop', '~> 0.75.1'
  s.add_development_dependency 'simplecov', '~> 0.16', '>= 0.16.1'
  s.add_development_dependency 'sqlite3', '~> 1.3', '>= 1.3.13'
  s.add_development_dependency 'pry', '~> 0.12.2'
end
