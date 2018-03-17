require "rabbit_api/resource_mapper"
require "rabbit_api/jwt_auth/json_web_token"
require "rabbit_api/response_formatters/renderer"

module RabbitApi
  module Modules
    include RabbitApi::ResourceMapper
    include RabbitApi::JwtAuth::JsonWebToken
    include RabbitApi::ResponseFormatters::Renderer
  end
end
