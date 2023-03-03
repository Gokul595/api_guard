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
        token = refresh_tokens_for(resource).where(token: refresh_token).where('expire_at IS NULL OR expire_at > ?', Time.now.utc).first
        return nil unless check_token_reuse(resource, token)

        token
      end

      def check_token_reuse(resource, refresh_token)
        return true if refresh_token.active
        destroy_refresh_token_family(resource, refresh_token)

        false
      end

      def destroy_refresh_token_family(resource, invalid_refresh_token)
        refresh_tokens_for(resource).where(refresh_token_id: invalid_refresh_token.id).destroy_all
        invalid_refresh_token.destroy
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
      def new_refresh_token(resource, expired_refresh_token = false, previous_refresh_token = nil)
        return unless refresh_token_enabled?(resource)

        new_token_data = { token: uniq_refresh_token(resource), active: 1, expire_at: expired_refresh_token ? Time.now.utc : refresh_token_expire_at }

        if previous_refresh_token
          previous_refresh_token.update(active: 0)
          new_token_data[:refresh_token_id] = previous_refresh_token.id
        end

        refresh_tokens_for(resource).create(new_token_data).token
      end

      def destroy_all_refresh_tokens(resource)
        return unless refresh_token_enabled?(resource)

        refresh_tokens_for(resource).destroy_all
      end
    end
  end
end
