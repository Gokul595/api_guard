# frozen_string_literal: true

class RefreshToken < ApplicationRecord
  # == Relationships ===================================================================================================
  belongs_to :user, optional: true
  belongs_to :admin, optional: true
end
