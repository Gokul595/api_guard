module RabbitApi
  module JwtAuth
    # Common module for refresh token functionality
    module RefreshJwtToken
      def find_refresh_token_of(resource, refresh_token)
        resource.refresh_tokens.find_by_token(refresh_token)
      end

      # Generate and return unique refresh token
      def uniq_refresh_token
        loop do
          random_token = SecureRandom.urlsafe_base64
          return random_token unless RefreshToken.exists?(token: random_token)
        end
      end

      # Create a new refresh_token for the current resource
      def new_refresh_token(resource)
        return nil unless RabbitApi.generate_refresh_token
        resource.refresh_tokens.create(token: uniq_refresh_token).token
      end

      def destroy_all_refresh_tokens(resource)
        return unless RabbitApi.generate_refresh_token
        resource.refresh_tokens.destroy_all
      end
    end
  end
end
