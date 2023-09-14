# frozen_string_literal: true

module ApiGuard
  module Models
    module Concerns
      extend ActiveSupport::Concern

      class_methods do
        def api_guard_associations(refresh_token: nil, revoked_token: nil)
          return if ApiGuard.api_guard_associations[name]

          ApiGuard.api_guard_associations[name] = {}
          ApiGuard.api_guard_associations[name][:refresh_token] = refresh_token
          ApiGuard.api_guard_associations[name][:revoked_token] = revoked_token
        end

        def refresh_token_association
          ApiGuard.api_guard_associations.dig(name, :refresh_token)
        end

        def revoked_token_association
          ApiGuard.api_guard_associations.dig(name, :revoked_token)
        end
      end
    end
  end
end
