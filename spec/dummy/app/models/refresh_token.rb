class RefreshToken < ApplicationRecord
  # == Relationships ===================================================================================================
  belongs_to :user
end
