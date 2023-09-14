module <%= @controller_scope %>
  class PasswordsController < ApiGuard::PasswordsController
    # before_action :authenticate_resource, only: [:update]

    # def update
    #   invalidate_old_jwt_tokens(current_resource)
    #
    #   if current_resource.update_attributes(password_params)
    #     revoke_token unless ApiGuard.invalidate_old_tokens_on_password_change
    #     destroy_all_refresh_tokens(current_resource)
    #
    #     create_token_and_set_header(current_resource, resource_name)
    #     render_success(message: I18n.t('api_guard.password.changed'))
    #   else
    #     render_error(422, object: current_resource)
    #   end
    # end

    # private

    # def password_params
    #   params.permit(:password, :password_confirmation)
    # end
  end
end
