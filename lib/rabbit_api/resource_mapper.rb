module RabbitApi
  class ResourceMapper
    attr_reader :resource_class_name, :resource_class, :resource_instance_name

    def initialize(routes_for, class_name)
      @resource_class_name = class_name
      @resource_class = @resource_class_name.constantize
      @resource_instance_name = "@rabbit_api_#{routes_for}"
    end
  end

  module Resource
    def resource
      instance_variable_get(mapped_resource_instance)
    end

    def resource=(new_resource)
      instance_variable_set(mapped_resource_instance, new_resource)
    end

    def current_resource_mapping
      request.env["rabbit_api.mapping"]
    end

    def resource_class_name
      current_resource_mapping.resource_class_name
    end

    def resource_class
      current_resource_mapping.resource_class
    end

    def mapped_resource_instance
      current_resource_mapping.resource_instance_name
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
