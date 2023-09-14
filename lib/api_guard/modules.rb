# frozen_string_literal: true

require 'api_guard/resource_mapper'
require 'api_guard/jwt_auth/json_web_token'
require 'api_guard/jwt_auth/authentication'
require 'api_guard/jwt_auth/refresh_jwt_token'
require 'api_guard/jwt_auth/revoke_token'
require 'api_guard/response_formatters/renderer'
require 'api_guard/models/concerns'

module ApiGuard
  module Modules
    ActiveSupport.on_load(:action_controller) do
      include ApiGuard::Resource
      include ApiGuard::JwtAuth::JsonWebToken
      include ApiGuard::JwtAuth::Authentication
      include ApiGuard::JwtAuth::RefreshJwtToken
      include ApiGuard::JwtAuth::RevokeToken
      include ApiGuard::ResponseFormatters::Renderer
    end

    ActiveSupport.on_load(:active_record) do
      include ApiGuard::Models::Concerns
    end
  end
end
