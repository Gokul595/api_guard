require "rabbit_api/engine"

module RabbitApi
  mattr_accessor :generate_refresh_token
  self.generate_refresh_token = false

  mattr_accessor :blacklist_token_on_sign_out
  self.blacklist_token_on_sign_out = false
end
