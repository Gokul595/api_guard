require_dependency 'api_guard/application_controller'

module ApiGuard
  class PasswordsController < ApplicationController
    before_action :authenticate_resource, only: [:update]

    def update
      invalidate_old_jwt_tokens(current_resource)

      if current_resource.update_attributes(password_params)
        blacklist_token
        destroy_all_refresh_tokens(current_resource)

        create_token_and_set_header(current_resource, resource_name)
        render_success(message: 'Password changed successfully')
      else
        render_error(422, object: current_resource)
      end
    end

    private

    def password_params
      params.require(resource_name.to_sym).permit(:password, :password_confirmation)
    end
  end
end
