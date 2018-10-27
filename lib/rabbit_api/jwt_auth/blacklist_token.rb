module RabbitApi
  module JwtAuth
    # Common module for token blacklisting functionality
    module BlacklistToken
      def blacklisted_token_association(resource)
        RabbitApi.rabbit_api_token_associations[resource.class.name][:blacklisted_token]
      end

      def token_blacklisting_enabled?(resource)
        blacklisted_token_association(resource)
      end

      def blacklisted_tokens_for(resource)
        blacklisted_token_association = blacklisted_token_association(resource)
        resource.send(blacklisted_token_association)
      end

      # Returns whether the JWT token is blacklisted or not
      def blacklisted?
        return false unless token_blacklisting_enabled?(current_resource)
        blacklisted_tokens_for(current_resource).exists?(token: @token)
      end

      # Blacklist the current JWT token from future access
      def blacklist_token
        return unless token_blacklisting_enabled?(current_resource)
        blacklisted_tokens_for(current_resource).create(token: @token, expire_at: Time.at(@decoded_token[:exp]).utc)
      end
    end
  end
end
