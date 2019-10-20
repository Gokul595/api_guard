# frozen_string_literal: true

module ApiGuard
  class ControllersGenerator < Rails::Generators::Base
    CONTROLLERS = %i[registration authentication tokens passwords].freeze

    desc 'Generates API Guard controllers in app/controllers/'
    source_root File.expand_path('templates', __dir__)

    argument :scope, required: true, desc: 'The scope to create controllers in, e.g. users, admins'

    class_option :controllers, aliases: '-c', type: :array,
                               desc: "Specify the controllers to generate (#{CONTROLLERS.join(', ')})"

    def create_controllers
      @controller_scope = scope.camelize
      controllers = options[:controllers] || CONTROLLERS

      controllers.each do |controller_name|
        template "#{controller_name}_controller.rb",
                 "app/controllers/#{scope}/#{controller_name}_controller.rb"
      end
    end
  end
end
