# frozen_string_literal: true

require_dependency 'api_guard/application_controller'

module ApiGuard
  class AuthenticationController < ApplicationController
    before_action :find_resource, only: [:create]
    before_action :authenticate_resource, only: [:destroy]

    def create
      if resource.authenticate(params[:password])
        create_token_and_set_header(resource, resource_name)
        render_success(message: I18n.t('api_guard.authentication.signed_in'))
      else
        render_error(422, message: I18n.t('api_guard.authentication.invalid_login_credentials'))
      end
    end

    def destroy
      blacklist_token
      render_success(message: I18n.t('api_guard.authentication.signed_out'))
    end

    private

    def find_resource
      if params[:email].present?
        self.resource = resource_class.find_by(email: params[:email].downcase.strip)
      end
      unless resource
        render_error(422, message: I18n.t('api_guard.authentication.invalid_login_credentials'))
      end
    end
  end
end
