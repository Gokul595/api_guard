require_dependency "rabbit_api/application_controller"

module RabbitApi
  class AuthenticationController < ApplicationController
    before_action :find_resource, only: [:create]
    before_action :authenticate_resource, only: [:destroy]

    def create
      if resource.authenticate(params[:password])
        create_token_and_set_header
        render_success(data: resource)
      else
        render_error(422, message: 'Invalid login credentials')
      end
    end

    def destroy
      # Destroy refresh token and blacklist JWT token
      destroy_and_blacklist_token
      render_success(message: 'Signed out successfully!')
    end

    private

    def find_resource
      self.resource = resource_class.find_by(email: params[:email].downcase.strip) if params[:email].present?
      render_error(422, message: 'Invalid login credentials') unless resource
    end
  end
end
