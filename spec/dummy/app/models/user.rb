class User < ApplicationRecord
  has_secure_password

  api_guard_associations refresh_token: 'refresh_tokens', blacklisted_token: 'blacklisted_tokens'

  # == Validations =====================================================================================================
  validates :email, presence: true
  validates :email, uniqueness: true, allow_blank: true

  # == Relationships ===================================================================================================
  has_many :refresh_tokens, dependent: :delete_all
  has_many :blacklisted_tokens, dependent: :delete_all
end
