# frozen_string_literal: true

module ApiGuard
  class ResourceMapper
    attr_reader :resource_name, :resource_class, :resource_instance_name

    def initialize(routes_for, class_name)
      @resource_name = routes_for.singularize
      @resource_class = class_name.constantize
      @resource_instance_name = "@api_guard_#{routes_for}"
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
      request.env['api_guard.mapping']
    end

    def resource_name
      current_resource_mapping.resource_name
    end

    def resource_class
      current_resource_mapping.resource_class
    end

    def mapped_resource_instance
      current_resource_mapping.resource_instance_name
    end

    def init_resource(params)
      self.resource = resource_class.new(params)
    end
  end
end
