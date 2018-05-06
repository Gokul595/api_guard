module RabbitApi
  module JwtAuth
    # Common module for API authentication
    module Authentication
      # Handle authentication of the resource dynamically
      def method_missing(name, *args)
        method_name = name.to_s

        if method_name.start_with?('authenticate_and_set_')
          resource_name = method_name.split('authenticate_and_set_')[1]
          authenticate_and_set_resource(resource_name)
        else
          super
        end
      end

      # Authenticate the JWT token and set resource
      def authenticate_and_set_resource(resource_name)
        @resource_name = resource_name

        authenticate_or_request_with_http_token do |token, _|
          @token = token
          authenticate_token
          true # Return true to handle 'Invalid access token' request separately
        end

        # Render error response only if no resource found and no previous render happened
        render_error(401, message: 'Invalid access token') if !current_resource && !performed?
      rescue JWT::DecodeError => e
        if e.message == 'Signature has expired'
          render_error(401, message: 'Token expired')
        else
          render_error(401, message: 'Invalid access token')
        end
      end

      # Override to send JSON response instead of plain HTML
      # if 'Authorization' header is empty or value of the header is invalid
      def request_http_token_authentication(realm = 'Application', _message = nil)
        render_error(401, message: 'Access token is missing in the request')
      end

      # Decode the JWT token
      # and don't verify token expiry for refresh token API request
      def decode_token
        verify_token = (controller_name != 'tokens' || action_name != 'create')
        @decoded_token = decode(@token, verify_token)
      end

      # Returns whether the JWT token is issued after the last password change
      # Returns true if password hasn't changed by the user
      def valid_issued_at?
        return true unless RabbitApi.invalidate_old_tokens_on_logout
        !current_resource.token_issued_at || @decoded_token[:iat] >= current_resource.token_issued_at.to_i
      end

      # Returns whether the JWT token is blacklisted or not
      def blacklisted?
        return false unless RabbitApi.blacklist_token_on_sign_out
        current_resource.blacklisted_tokens.exists?(token: @token)
      end

      # Authenticate the resource with the '{{resource_name}}_id' in the decoded JWT token
      # and also, check for valid issued at time and not blacklisted
      #
      # Also, set "current_{{resource_name}}" method and "@current_{{resource_name}}" instance variable
      # for accessing the authenticated resource
      def authenticate_token
        return unless decode_token && @decoded_token[:"#{@resource_name}_id"].present?

        resource = @resource_name.classify.constantize.find_by(id: @decoded_token[:"#{@resource_name}_id"])

        self.class.send(:define_method, "current_#{@resource_name}") do
          instance_variable_get("@current_#{@resource_name}") || instance_variable_set("@current_#{@resource_name}", resource)
        end

        return if current_resource && valid_issued_at? && !blacklisted?

        render_error(401, message: 'Invalid access token')
      end

      def current_resource
        defined? public_send("current_#{@resource_name}") ? public_send("current_#{@resource_name}") : nil
      end
    end
  end
end
