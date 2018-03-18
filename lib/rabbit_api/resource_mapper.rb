module RabbitApi
  class ResourceMapper
    attr_reader :resource_class_name, :resource_class, :resource_mapping

    def initialize(routes_for, class_name)
      @resource_class_name = class_name
      @resource_class = @resource_class_name.constantize
      @resource_mapping = "@rabbit_api_#{routes_for}"
    end
  end

  module Resource
    def resource
      instance_variable_get(resource_mapping)
    end

    def resource=(new_resource)
      instance_variable_set(resource_mapping, new_resource)
    end

    def rabbit_mapping
      request.env["rabbit_api.mapping"]
    end

    def resource_class_name
      rabbit_mapping.resource_class_name
    end

    def resource_class
      rabbit_mapping.resource_class
    end

    def resource_mapping
      rabbit_mapping.resource_mapping
    end

    def init_resource(params)
      # TODO: Check whether `self` is ok.
      self.resource = resource_class.new(params)
    end

    def find_resource
      self.resource = resource_class.find_by(email: params[:email].downcase.strip) if params[:email].present?
      render_error(422, message: 'Invalid login credentials') unless resource
    end
  end
end
