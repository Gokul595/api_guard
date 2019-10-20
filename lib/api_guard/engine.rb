# frozen_string_literal: true

module ApiGuard
  class Engine < ::Rails::Engine
    isolate_namespace ApiGuard

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    # Use 'secret_key_base' from Rails secrets if 'token_signing_secret' is not configured
    initializer 'ApiGuard.token_signing_secret' do |app|
      ApiGuard.token_signing_secret ||= ApiGuard::AppSecretKey.new(app).detect
    end
  end
end
