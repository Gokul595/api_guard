# frozen_string_literal: true

module ApiGuard
  module JwtAuth
    # Common module for refresh token functionality
    module RefreshJwtToken

      def refresh_token_expire_at
        @refresh_token_expire_at ||= (Time.now.utc + ApiGuard.refresh_token_validity)
      end

      def refresh_token_association(resource)
        resource.class.refresh_token_association
      end

      def refresh_token_enabled?(resource)
        refresh_token_association(resource).present?
      end

      def refresh_tokens_for(resource)
        refresh_token_association = refresh_token_association(resource)
        resource.send(refresh_token_association)
      end

      def find_refresh_token_of(resource, refresh_token)
        refresh_tokens_for(resource).where(token: refresh_token).where('expire_at IS NULL OR expire_at > ?', Time.now.utc).first
      end

      # Generate and return unique refresh token for the resource
      def uniq_refresh_token(resource)
        loop do
          random_token = SecureRandom.urlsafe_base64
          return random_token unless refresh_tokens_for(resource).exists?(token: random_token)
        end
      end

      # Create a new refresh_token for the current resource
      # This creates expired refresh_token if the argument 'expired_refresh_token' is true which can be used for testing.
      def new_refresh_token(resource, expired_refresh_token = false)
        return unless refresh_token_enabled?(resource)

        refresh_tokens_for(resource).create(token: uniq_refresh_token(resource), expire_at: expired_refresh_token ? Time.now.utc : refresh_token_expire_at).token
      end

      def destroy_all_refresh_tokens(resource)
        return unless refresh_token_enabled?(resource)

        refresh_tokens_for(resource).destroy_all
      end
    end
  end
end
