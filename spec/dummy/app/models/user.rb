class User < ApplicationRecord
  has_secure_password

  # == Validations =====================================================================================================
  validates :email, presence: true
  validates :email, uniqueness: true, allow_blank: true

  # == Relationships ===================================================================================================
  has_many :refresh_tokens
end
