# frozen_string_literal: true

module ApiGuard
  class AppSecretKey
    def initialize(application)
      @application = application
    end

    def detect
      secret_key_base(:credentials) || secret_key_base(:secrets) ||
        secret_key_base(:config) || secret_key_base
    end

    private

    def secret_key_base(source = nil)
      return @application.secret_key_base unless source

      @application.send(source).secret_key_base.presence if @application.respond_to?(source)
    end
  end
end
