require_dependency 'api_guard/application_controller'

module ApiGuard
  class AuthenticationController < ApplicationController
    # before_action :find_resource, only: [:create]
    # before_action :authenticate_resource, only: [:destroy]

    # def create
    #   if resource.authenticate(params[:password])
    #     create_token_and_set_header(resource, resource_name)
    #     render_success(data: resource)
    #   else
    #     render_error(422, message: 'Invalid login credentials')
    #   end
    # end

    # def destroy
    #   blacklist_token
    #   render_success(message: 'Signed out successfully')
    # end

    # private

    # def find_resource
    #   self.resource = resource_class.find_by(email: params[:email].downcase.strip) if params[:email].present?
    #   render_error(422, message: 'Invalid login credentials') unless resource
    # end
  end
end
