require "rabbit_api/engine"
require "rabbit_api/modules"

module RabbitApi
  mattr_accessor :generate_refresh_token
  self.generate_refresh_token = false

  mattr_accessor :invalidate_old_tokens_on_logout
  self.invalidate_old_tokens_on_logout = false

  mattr_accessor :blacklist_token_on_sign_out
  self.blacklist_token_on_sign_out = false
end
