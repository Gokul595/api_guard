require_dependency 'rabbit_api/application_controller'

module RabbitApi
  class PasswordsController < ApplicationController
    before_action :authenticate_resource, only: [:update]

    def update
      # Update token issued at timestamp to access to old access tokens
      current_resource.token_issued_at = Time.at(token_issued_at).utc if RabbitApi.invalidate_old_tokens_on_password_change

      if current_resource.update_attributes(password_params)
        blacklist_token
        current_resource.refresh_tokens.destroy_all if RabbitApi.generate_refresh_token

        create_token_and_set_header(current_resource, resource_name)
        render_success(data: current_resource)
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
