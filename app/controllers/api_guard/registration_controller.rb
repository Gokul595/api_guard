# frozen_string_literal: true

require_dependency 'api_guard/application_controller'

module ApiGuard
  class RegistrationController < ApplicationController
    before_action :authenticate_resource, only: [:destroy]

    def create
      init_resource(sign_up_params)
      if resource.save
        create_and_set_token_pair(resource, resource_name)
        render_success(data: resource, message: I18n.t('api_guard.registration.signed_up'))
      else
        render_error(422, object: resource)
      end
    end

    def destroy
      current_resource.destroy
      remove_tokens_from_cookies
      render_success(data: nil, message: I18n.t('api_guard.registration.account_deleted'))
    end

    private

    def sign_up_params
      params.permit(:email, :password, :password_confirmation)
    end
  end
end
