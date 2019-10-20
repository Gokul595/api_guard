# frozen_string_literal: true

ApiGuard.setup do |config|
  # Validity of the JWT access token
  # Default: 1 day
  # config.token_validity = 1.day

  # Secret key for signing (encoding & decoding) the JWT access token
  # Default: 'secret_key_base' from Rails secrets
  # config.token_signing_secret = 'my_signing_secret'

  # Invalidate old tokens on changing the password
  # Default: false
  # config.invalidate_old_tokens_on_password_change = false

  # Blacklist JWT access token after refreshing
  # Default: false
  # config.blacklist_token_after_refreshing = false
end
