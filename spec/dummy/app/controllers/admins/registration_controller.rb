module Admins
  class RegistrationController < RabbitApi::RegistrationController
    before_action :disable_refresh_token
    after_action :enable_refresh_token

    def create
      super
    end

    def destroy
      super
    end

    private

    # Disable refresh token functionality
    def disable_refresh_token
      RabbitApi.generate_refresh_token = false
    end

    # Enable refresh token functionality
    def enable_refresh_token
      RabbitApi.generate_refresh_token = true
    end
  end
end
