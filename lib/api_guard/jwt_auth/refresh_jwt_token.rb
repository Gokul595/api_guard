module ApiGuard
  module JwtAuth
    # Common module for refresh token functionality
    module RefreshJwtToken
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
        refresh_tokens_for(resource).find_by_token(refresh_token)
      end

      # Generate and return unique refresh token for the resource
      def uniq_refresh_token(resource)
        loop do
          random_token = SecureRandom.urlsafe_base64
          return random_token unless refresh_tokens_for(resource).exists?(token: random_token)
        end
      end

      # Create a new refresh_token for the current resource
      def new_refresh_token(resource)
        return unless refresh_token_enabled?(resource)

        refresh_tokens_for(resource).create(token: uniq_refresh_token(resource)).token
      end

      def destroy_all_refresh_tokens(resource)
        return unless refresh_token_enabled?(resource)

        refresh_tokens_for(resource).destroy_all
      end
    end
  end
end
