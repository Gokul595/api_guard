# frozen_string_literal: true

# Referenced from devise gem:
# https://github.com/plataformatec/devise/blob/master/lib/devise/rails/routes.rb
#
# Customizable API routes
module ActionDispatch
  module Routing
    class Mapper
      def api_guard_routes(options = {})
        routes_for = options.delete(:for).to_s || 'users'

        controllers = default_controllers(options[:only], options[:except])
        controller_options = options.delete(:controller)

        options[:as] = options[:as] || routes_for.singularize
        options[:path] = options[:path] || routes_for

        api_guard_scope(routes_for) do |mapped_resource|
          scope options do
            generate_routes(mapped_resource, controller_options, controllers)
          end
        end
      end

      def api_guard_scope(routes_for)
        mapped_resource = ApiGuard.mapped_resource[routes_for.to_sym].presence ||
                          ApiGuard.map_resource(routes_for, routes_for.classify)

        constraint = lambda do |request|
          request.env['api_guard.mapping'] = mapped_resource
          true
        end

        constraints(constraint) do
          yield(mapped_resource)
        end
      end

      private

      def default_controllers(only, except)
        return only if only

        controllers = %i[registration authentication tokens passwords]
        except ? (controllers - except) : controllers
      end

      def generate_routes(mapped_resource, options, controllers)
        options ||= {}
        controllers -= %i[tokens] unless mapped_resource.resource_class.refresh_token_association

        controllers.each do |controller|
          send("#{controller}_routes", options[controller])
        end
      end

      def authentication_routes(controller_name = nil)
        controller_name ||= 'api_guard/authentication'

        post 'sign_in' => "#{controller_name}#create"
        delete 'sign_out' => "#{controller_name}#destroy"
      end

      def registration_routes(controller_name = nil)
        controller_name ||= 'api_guard/registration'

        post 'sign_up' => "#{controller_name}#create"
        delete 'delete' => "#{controller_name}#destroy"
      end

      def passwords_routes(controller_name = nil)
        controller_name ||= 'api_guard/passwords'

        patch 'passwords' => "#{controller_name}#update"
      end

      def tokens_routes(controller_name = nil)
        controller_name ||= 'api_guard/tokens'

        post 'tokens' => "#{controller_name}#create"
      end
    end
  end
end
