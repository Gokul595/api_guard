module RabbitApi
  module Models
    module Concerns
      extend ActiveSupport::Concern

      class_methods do
        def rabbit_token_associations(refresh_token: nil, blacklisted_token: nil)
          return if RabbitApi.rabbit_api_token_associations[self.class.name]

          RabbitApi.rabbit_api_token_associations[self.name] = {}
          RabbitApi.rabbit_api_token_associations[self.name][:refresh_token] = refresh_token
          RabbitApi.rabbit_api_token_associations[self.name][:blacklisted_token] = blacklisted_token
        end
      end
    end
  end
end
