# Referenced from devise gem:
# https://github.com/plataformatec/devise/blob/master/lib/devise/rails/routes.rb
#
# Customizable API routes
module ActionDispatch::Routing
  class Mapper
    def rabbit_api_routes(options = {})
      routes_for = options.delete(:for).tableize || 'users'
      class_name = (options.delete(:class_name) || routes_for).classify

      options[:module] = options[:module] || 'rabbit_api'
      options[:as] = options[:as] || routes_for.singularize
      options[:path] = options[:path] || routes_for

      RabbitApi.map_resource(routes_for, class_name)

      rabbit_api_scope(routes_for) do
        scope options do
          post 'sign_in' => 'authentication#create'
          delete 'sign_out' => 'authentication#destroy'

          post 'sign_up' => 'registration#create'
          delete 'sign_down' => 'registration#destroy' # TODO: Rename this route path
        end
      end
    end

    private

    def rabbit_api_scope(routes_for)
      constraint = lambda do |request|
        request.env["rabbit_api.mapping"] = RabbitApi.mapped_resource[routes_for]
        true
      end

      constraints(constraint) do
        yield
      end
    end
  end
end
