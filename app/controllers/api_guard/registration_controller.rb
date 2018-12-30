require_dependency 'api_guard/application_controller'

module ApiGuard
  class RegistrationController < ApplicationController
    def create
      init_resource(sign_up_params)
      if resource.save
        create_token_and_set_header(resource, resource_name)
        render_success(data: resource, message: "#{resource_name.capitalize} created successfully")
      else
        render_error(422, object: resource)
      end
    end

    def destroy
      resource.destroy
      render_success(message: "#{resource_name.capitalize} destroyed successfully")
    end

    private

    def sign_up_params
      params.require(resource_name.to_sym).permit(:email, :password, :password_confirmation)
    end
  end
end
