# frozen_string_literal: true

require 'jwt'

module ApiGuard
  module JwtAuth
    # Common module for JWT operations
    module JsonWebToken
      def current_time
        @current_time ||= Time.now.utc
      end

      def token_expire_at
        @token_expire_at ||= (current_time + ApiGuard.token_validity).to_i
      end

      def token_issued_at
        @token_issued_at ||= current_time.to_i
      end

      # Encode the payload with the secret key and return the JWT token
      def encode(payload)
        JWT.encode(payload, ApiGuard.token_signing_secret)
      end

      # Decode the JWT token and return the payload
      def decode(token, verify = true)
        HashWithIndifferentAccess.new(
          JWT.decode(token, ApiGuard.token_signing_secret, verify, verify_iat: true)[0]
        )
      end

      # Create a JWT token with resource detail in payload.
      # Also, create refresh token if enabled for the resource.
      #
      # This creates expired JWT token if the argument 'expired_token' is true which can be used for testing.
      # This creates expired refresh token if the argument 'expired_refresh_token' is true which can be used for testing.
      def jwt_and_refresh_token(resource, resource_name, expired_token = false, expired_refresh_token = false)
        payload = {
          "#{resource_name}_id": resource.id,
          exp: expired_token ? token_issued_at : token_expire_at,
          iat: token_issued_at
        }

        # Add custom data in the JWT token payload
        payload.merge!(resource.jwt_token_payload) if resource.respond_to?(:jwt_token_payload)

        [encode(payload), new_refresh_token(resource, expired_refresh_token)]
      end

      # Create tokens and set response headers
      def create_token_and_set_header(resource, resource_name)
        access_token, refresh_token = jwt_and_refresh_token(resource, resource_name)
        set_token_headers(access_token, refresh_token)
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
