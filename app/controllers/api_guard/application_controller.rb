module ApiGuard
  class ApplicationController < ActionController::Base
    include ApiGuard::Modules

    def authenticate_resource
      public_send("authenticate_and_set_#{resource_name}")
    end
  end
end
