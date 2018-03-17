require_dependency "rabbit_api/application_controller"

module RabbitApi
  class RegistrationController < ApplicationController
    def create
      init_resource(sign_up_params)
      if resource.save
        create_token_and_set_header
        render_success(data: resource, message: "#{resource_class_name} created successfully")
      else
        render_error(422, object: resource)
      end
    end

    def destroy
      resource.destroy
      render_success(message: "#{resource_class_name} destroyed successfully")
    end

    private

    def sign_up_params
      params.require(resource_class_name.downcase.to_sym).permit(:email, :password, :password_confirmation)
    end
  end
end
