# frozen_string_literal: true

class BlacklistedToken < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :admin, optional: true
end
