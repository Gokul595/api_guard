class User < ApplicationRecord
  has_secure_password

  rabbit_token_associations refresh_token: 'refresh_tokens'

  # == Validations =====================================================================================================
  validates :email, presence: true
  validates :email, uniqueness: true, allow_blank: true

  # == Relationships ===================================================================================================
  has_many :refresh_tokens
end
