# frozen_string_literal: true

module ApiGuard
  class InitializerGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc 'Creates initializer for configuring API Guard'

    def create_initializer
      copy_file 'initializer.rb', 'config/initializers/api_guard.rb'
    end
  end
end
