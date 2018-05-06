module RabbitApi
  class ApplicationController < ActionController::Base
    include RabbitApi::Modules

    def authenticate_resource
      public_send("authenticate_and_set_#{resource_name}")
    end
  end
end
