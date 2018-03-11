require_dependency "rabbit_api/application_controller"

module RabbitApi
  class AuthenticationController < ApplicationController
    before_action :find_user, only: [:create]

    def create
      if @user.authenticate(params[:password])
        create_token_and_set_header
        render_success(data: @user)
      else
        render_error(422, message: 'Invalid login credentials')
      end
    end

    def destroy
      # Destroy refresh token and blacklist JWT token
      destroy_and_blacklist_token
      render_success(message: 'Signed out successfully!')
    end

    private

    def find_user
      @user = User.find_by(email: params[:email].downcase.strip) if params[:email].present?
      render_error(422, 'Invalid login credentials') unless @user
    end
  end
end
