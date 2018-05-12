class User < ApplicationRecord
  has_secure_password

  # == Validations =====================================================================================================
  validates :email, presence: true, uniqueness: true
  validates :email, uniqueness: true, allow_blank: true
end
