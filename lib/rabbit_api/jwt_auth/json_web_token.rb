require 'jwt'

module RabbitApi
  module JwtAuth
    # Common module for JWT operations
    module JsonWebToken
      def current_time
        @current_time ||= Time.now.utc
      end

      def token_expire_at
        @expire_at ||= (current_time + 30.minutes).to_i
      end

      def token_issued_at
        @issued_at ||= current_time.to_i
      end

      # Encode the payload with the secret key and return the JWT token
      def encode(payload)
        JWT.encode(payload, Rails.application.secrets.secret_key_base)
      end

      # Decode the JWT token and return the payload
      def decode(token, verify = true)
        HashWithIndifferentAccess.new(
          JWT.decode(token, Rails.application.secrets.secret_key_base, verify, verify_iat: true)[0]
        )
      end

      # Create a JWT token with resource detail in payload.
      # Also, create refresh token and return both JWT and refresh token.
      def create_token_and_set_header
        token = encode(
          "#{resource_name}_id": resource.id,
          exp: token_expire_at,
          iat: token_issued_at
        )

        # Update token issued at timestamp
        resource.update_attributes(token_issued_at: Time.at(token_issued_at).utc) if RabbitApi.invalidate_old_tokens_on_logout

        new_refresh_token = create_or_update_refresh_token if RabbitApi.generate_refresh_token

        set_token_headers(token, new_refresh_token)
      end

      # Generate and return unique refresh token
      def uniq_refresh_token
        loop do
          random_token = SecureRandom.urlsafe_base64
          return random_token unless RefreshToken.exists?(token: random_token)
        end
      end

      # Update existing refresh_token if available for resource or create a new refresh_token
      # FIXME: Don't update token instead always create new one
      def create_or_update_refresh_token
        new_refresh_token = uniq_refresh_token
        refresh_token = resource.refresh_token

        if refresh_token
          refresh_token.update_attributes(token: new_refresh_token)
        else
          resource.create_refresh_token(token: new_refresh_token)
        end

        new_refresh_token
      end

      # Destroy refresh token and blacklist JWT token
      def destroy_and_blacklist_token
        current_resource.refresh_token.destroy if RabbitApi.generate_refresh_token
        # Blacklist the current token from future use.
        current_resource.blacklisted_tokens.create(token: @token, expire_at: Time.at(@decoded_token[:exp]).utc) if RabbitApi.blacklist_token_on_sign_out
      end

      # Set token details in response headers on successful authentication
      def set_token_headers(token, refresh_token = nil)
        response.headers['Access-Token'] = token
        response.headers['Refresh-Token'] = refresh_token if refresh_token
        response.headers['Expire-At'] = token_expire_at.to_s
      end

      def current_resource
        public_send("current_#{resource_name}")
      end
    end
  end
end
