# frozen_string_literal: true

module ApiGuard
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
