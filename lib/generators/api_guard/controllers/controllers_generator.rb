class ApiGuard::ControllersGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc 'Generates all API Guard controllers in app/controllers/api_guard'

  def create_controllers
    controllers = %i[registration authentication tokens passwords]

    controllers.each do |controller_name|
      copy_file "#{controller_name}_controller.rb", "app/controllers/api_guard/#{controller_name}_controller.rb"
    end
  end
end
