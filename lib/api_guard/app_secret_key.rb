module ApiGuard
  class AppSecretKey
    def initialize(application)
      @application = application
    end

    def detect
      if @application.respond_to?(:credentials) && secret_key_present?(@application.credentials)
        @application.credentials.secret_key_base
      elsif @application.respond_to?(:secrets) && secret_key_present?(@application.secrets)
        @application.secrets.secret_key_base
      elsif @application.config.respond_to?(:secret_key_base) && secret_key_present?(@application.config)
        @application.config.secret_key_base
      elsif @application.respond_to?(:secret_key_base) && secret_key_present?(@application)
        @application.secret_key_base
      end
    end

    private

    def secret_key_present?(config)
      config.secret_key_base.present?
    end
  end
end
