require "rabbit_api/resource_mapper"
require "rabbit_api/jwt_auth/json_web_token"
require "rabbit_api/jwt_auth/authentication"
require "rabbit_api/jwt_auth/refresh_jwt_token"
require "rabbit_api/jwt_auth/blacklist_token"
require "rabbit_api/response_formatters/renderer"
require "rabbit_api/models/concerns"

module RabbitApi
  module Modules
    include RabbitApi::Resource
    include RabbitApi::JwtAuth::JsonWebToken
    include RabbitApi::JwtAuth::Authentication
    include RabbitApi::JwtAuth::RefreshJwtToken
    include RabbitApi::JwtAuth::BlacklistToken
    include RabbitApi::ResponseFormatters::Renderer

    ActiveSupport.on_load(:active_record) {
      include RabbitApi::Models::Concerns
    }
  end
end
