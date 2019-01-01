# Referenced from devise gem:
# https://github.com/plataformatec/devise/blob/master/lib/devise/rails/routes.rb
#
# Customizable API routes
module ActionDispatch::Routing
  class Mapper
    def api_guard_routes(options = {})
      routes_for = options.delete(:for).to_s || 'users'

      controllers = controllers(options[:only], options[:except])
      controller_options = options.delete(:controller)

      options[:as] = options[:as] || routes_for.singularize
      options[:path] = options[:path] || routes_for

      api_guard_scope(routes_for) do
        scope options do
          generate_routes(controller_options, controllers)
        end
      end
    end

    def api_guard_scope(routes_for)
      ApiGuard.map_resource(routes_for, routes_for.classify) unless ApiGuard.mapped_resource[routes_for.to_sym]

      constraint = lambda do |request|
        request.env["api_guard.mapping"] = ApiGuard.mapped_resource[routes_for.to_sym]
        true
      end

      constraints(constraint) do
        yield
      end
    end

    private

    def controllers(only, except)
      return only if only

      controllers = %i[registration authentication tokens passwords]
      except ? (controllers - except) : controllers
    end

    def generate_routes(options, controllers)
      options ||= {}

      controllers.each do |controller|
        send("#{controller.to_s}_routes", options[controller])
      end
    end

    def authentication_routes(controller_name = nil)
      controller_name = controller_name || 'api_guard/authentication'

      post 'sign_in' => "#{controller_name}#create"
      delete 'sign_out' => "#{controller_name}#destroy"
    end

    def registration_routes(controller_name = nil)
      controller_name = controller_name || 'api_guard/registration'

      post 'sign_up' => "#{controller_name}#create"
      delete 'delete' => "#{controller_name}#destroy"
    end

    def passwords_routes(controller_name = nil)
      controller_name = controller_name || 'api_guard/passwords'

      patch 'passwords' => "#{controller_name}#update"
    end

    def tokens_routes(controller_name = nil)
      controller_name = controller_name || 'api_guard/tokens'

      post 'tokens' => "#{controller_name}#create"
    end
  end
end
