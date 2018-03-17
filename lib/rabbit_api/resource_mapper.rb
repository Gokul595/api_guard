module RabbitApi
  module ResourceMapper
    def resource
      instance_variable_get(resource_mapping)
    end

    def resource=(new_resource)
      instance_variable_set(resource_mapping, new_resource)
    end

    def resource_class_name
      # Return authenticate resource name if 'params[:resource_class]' is nil
      @resource_class_name ||= params[:resource_class] || 'User'
    end

    def resource_class
      @resource_class ||= resource_class_name.constantize
    end

    def resource_mapping
      @resource_mapping ||= "@rabbit_api_#{resource_class_name.downcase}"
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
