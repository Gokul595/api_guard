require "api_guard/engine"
require "api_guard/route_mapper"
require "api_guard/modules"

module ApiGuard
  mattr_accessor :token_validity
  self.token_validity = 1.day

  mattr_accessor :invalidate_old_tokens_on_password_change
  self.invalidate_old_tokens_on_password_change = false

  mattr_accessor :api_guard_token_associations
  self.api_guard_token_associations = {}

  mattr_reader :mapped_resource
  @@mapped_resource = {}

  def self.setup
    yield self
  end

  def self.map_resource(routes_for, class_name)
    @@mapped_resource[routes_for.to_sym] = ApiGuard::ResourceMapper.new(routes_for, class_name)
  end
end
