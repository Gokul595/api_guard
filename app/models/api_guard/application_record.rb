module ApiGuard
  class ApplicationRecord < ActiveRecord::Base
    include ApiGuard::Models::Concerns

    self.abstract_class = true
  end
end
