module ApiGuard
  class Engine < ::Rails::Engine
    isolate_namespace ApiGuard

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    # Use 'secret_key_base' from Rails secrets if 'token_signing_secret' is not configured
    initializer 'ApiGuard.token_signing_secret' do |app|
      unless ApiGuard.token_signing_secret
        signing_secret = app.respond_to?(:credentials) ? app.credentials.secret_key_base : app.secrets.secret_key_base
        ApiGuard.token_signing_secret = signing_secret
      end
    end
  end
end
