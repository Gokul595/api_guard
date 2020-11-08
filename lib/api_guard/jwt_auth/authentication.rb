# frozen_string_literal: true

module ApiGuard
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

      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s.start_with?('authenticate_and_set_') || super
      end

      # Authenticate the JWT token and set resource
      def authenticate_and_set_resource(resource_name)
        @resource_name = resource_name

        @token = request.headers['Authorization']&.split('Bearer ')&.last
        return render_error(401, message: I18n.t('api_guard.access_token.missing')) unless @token

        authenticate_token

        # Render error response only if no resource found and no previous render happened
        render_error(401, message: I18n.t('api_guard.access_token.invalid')) if !current_resource && !performed?
      rescue JWT::DecodeError => e
        if e.message == 'Signature has expired'
          render_error(401, message: I18n.t('api_guard.access_token.expired'))
        else
          render_error(401, message: I18n.t('api_guard.access_token.invalid'))
        end
      end

      # Decode the JWT token
      # and don't verify token expiry for refresh token API request
      def decode_token
        # TODO: Set token refresh controller dynamic
        verify_token = (controller_name != 'tokens' || action_name != 'create')
        @decoded_token = decode(@token, verify_token)
      end

      # Returns whether the JWT token is issued after the last password change
      # Returns true if password hasn't changed by the user
      def valid_issued_at?(resource)
        return true unless ApiGuard.invalidate_old_tokens_on_password_change

        !resource.token_issued_at || @decoded_token[:iat] >= resource.token_issued_at.to_i
      end

      # Defines "current_{{resource_name}}" method and "@current_{{resource_name}}" instance variable
      # that returns "resource" value
      def define_current_resource_accessors(resource)
        define_singleton_method("current_#{@resource_name}") do
          instance_variable_get("@current_#{@resource_name}") ||
            instance_variable_set("@current_#{@resource_name}", resource)
        end
      end

      # Authenticate the resource with the '{{resource_name}}_id' in the decoded JWT token
      # and also, check for valid issued at time and not blacklisted
      #
      # Also, set "current_{{resource_name}}" method and "@current_{{resource_name}}" instance variable
      # for accessing the authenticated resource
      def authenticate_token
        return unless decode_token

        resource = find_resource_from_token(@resource_name.classify.constantize)

        if resource && valid_issued_at?(resource) && !blacklisted?(resource)
          define_current_resource_accessors(resource)
        else
          render_error(401, message: I18n.t('api_guard.access_token.invalid'))
        end
      end

      def find_resource_from_token(resource_class)
        resource_id = @decoded_token[:"#{@resource_name}_id"]
        return if resource_id.blank?

        resource_class.find_by(id: resource_id)
      end

      def current_resource
        return unless respond_to?("current_#{@resource_name}")

        public_send("current_#{@resource_name}")
      end
    end
  end
end
