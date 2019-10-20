# frozen_string_literal: true

ApiGuard.setup do |config|
  config.token_validity = 1.hour

  config.invalidate_old_tokens_on_password_change = true
end
