module ApiGuard
  module Models
    module Concerns
      extend ActiveSupport::Concern

      class_methods do
        def api_guard_associations(refresh_token: nil, blacklisted_token: nil)
          return if ApiGuard.api_guard_associations[self.name]

          ApiGuard.api_guard_associations[self.name] = {}
          ApiGuard.api_guard_associations[self.name][:refresh_token] = refresh_token
          ApiGuard.api_guard_associations[self.name][:blacklisted_token] = blacklisted_token
        end

        def refresh_token_association
          ApiGuard.api_guard_associations.dig(self.name, :refresh_token)
        end

        def blacklisted_token_association
          ApiGuard.api_guard_associations.dig(self.name, :blacklisted_token)
        end
      end
    end
  end
end
