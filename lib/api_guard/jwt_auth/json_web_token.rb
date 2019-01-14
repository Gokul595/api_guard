require 'jwt'

module ApiGuard
  module JwtAuth
    # Common module for JWT operations
    module JsonWebToken
      def current_time
        @current_time ||= Time.now.utc
      end

      def token_expire_at
        @expire_at ||= (current_time + ApiGuard.token_validity).to_i
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
      # Also, create refresh token and set in response headers
      def create_token_and_set_header(resource, resource_name)
        token = encode(
          "#{resource_name}_id": resource.id,
          exp: token_expire_at,
          iat: token_issued_at
        )

        set_token_headers(token, new_refresh_token(resource))
      end

      # Set token details in response headers
      def set_token_headers(token, refresh_token = nil)
        response.headers['Access-Token'] = token
        response.headers['Refresh-Token'] = refresh_token if refresh_token
        response.headers['Expire-At'] = token_expire_at.to_s
      end

      # Set token issued at to current timestamp
      # to restrict access to old access(JWT) tokens
      def invalidate_old_jwt_tokens(resource)
        return unless ApiGuard.invalidate_old_tokens_on_password_change
        resource.token_issued_at = Time.at(token_issued_at).utc
      end
    end
  end
end
