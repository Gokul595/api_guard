# frozen_string_literal: true

module ApiGuard
  module JwtAuth
    # Common module for token revocation functionality
    module RevokeToken
      def revoked_token_association(resource)
        resource.class.revoked_token_association
      end

      def token_revocation_enabled?(resource)
        revoked_token_association(resource).present?
      end

      def revoked_tokens_for(resource)
        revoked_token_association = revoked_token_association(resource)
        resource.send(revoked_token_association)
      end

      # Returns whether the JWT token is revoked or not
      def revoked?(resource)
        return false unless token_revocation_enabled?(resource)

        revoked_tokens_for(resource).exists?(token: @token)
      end

      # Revoke the current JWT token from future access
      def revoke_token
        return unless token_revocation_enabled?(current_resource)

        revoked_tokens_for(current_resource).create(token: @token, expire_at: Time.at(@decoded_token[:exp]).utc)
      end
    end
  end
end
