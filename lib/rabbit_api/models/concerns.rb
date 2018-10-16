module RabbitApi
  module Models
    module Concerns
      extend ActiveSupport::Concern

      included do
        cattr_accessor :rabbit_api_token_associations
        self.rabbit_api_token_associations = {}
      end

      class_methods do
        def rabbit_token_associations(refresh_token: nil, blacklisted_token: nil)
          return if self.rabbit_api_token_associations[self.class.name]

          self.rabbit_api_token_associations[self.name] = {}
          self.rabbit_api_token_associations[self.name][:refresh_token] = refresh_token
          self.rabbit_api_token_associations[self.name][:blacklisted_token] = blacklisted_token
        end
      end
    end
  end
end
