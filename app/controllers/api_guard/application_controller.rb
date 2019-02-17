module ApiGuard
  class ApplicationController < ActionController::Base
    def authenticate_resource
      public_send("authenticate_and_set_#{resource_name}")
    end
  end
end
