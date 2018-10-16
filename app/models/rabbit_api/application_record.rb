module RabbitApi
  class ApplicationRecord < ActiveRecord::Base
    include RabbitApi::Models::Concerns

    self.abstract_class = true
  end
end
