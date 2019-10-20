# frozen_string_literal: true

require 'api_guard/jwt_auth/json_web_token'
require 'api_guard/jwt_auth/refresh_jwt_token'

module ApiGuard
  module Test
    module ControllerHelper
      include ApiGuard::JwtAuth::JsonWebToken
      include ApiGuard::JwtAuth::RefreshJwtToken
    end
  end
end
