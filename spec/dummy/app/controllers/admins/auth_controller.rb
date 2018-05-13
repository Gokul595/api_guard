module Admins
  class AuthController < RabbitApi::AuthenticationController
    before_action :disable_refresh_token
    before_action :find_resource, only: [:create]
    after_action :enable_refresh_token

    def create
      if resource.authenticate(params[:password])
        create_token_and_set_header(resource, resource_name)
        render_success(data: resource)
      else
        render_error(401, message: 'Invalid admin credentials')
      end
    end

    def destroy
      super
    end

    private

    def find_resource
      self.resource = Admin.find_by(email: params[:email])
      render_error(401, message: 'Invalid admin credentials') unless resource
    end

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
