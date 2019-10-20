# frozen_string_literal: true

module ApiGuard
  class ApplicationController < ActionController::Base
    skip_before_action :verify_authenticity_token, raise: false

    def authenticate_resource
      public_send("authenticate_and_set_#{resource_name}")
    end
  end
end
