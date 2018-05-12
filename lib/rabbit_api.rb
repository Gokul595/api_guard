require "rabbit_api/engine"
require "rabbit_api/route_mapper"
require "rabbit_api/modules"

module RabbitApi
  mattr_accessor :generate_refresh_token
  self.generate_refresh_token = false

  mattr_accessor :invalidate_old_tokens_on_logout
  self.invalidate_old_tokens_on_logout = false

  mattr_accessor :blacklist_token_on_sign_out
  self.blacklist_token_on_sign_out = false

  mattr_reader :mapped_resource
  @@mapped_resource = {}

  def self.setup
    yield self
  end

  def self.map_resource(routes_for, class_name)
    @@mapped_resource[routes_for.to_sym] = RabbitApi::ResourceMapper.new(routes_for, class_name)
  end
end
