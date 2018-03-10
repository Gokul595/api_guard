require_dependency "rabbit_api/application_controller"

module RabbitApi
  class UsersController < ApplicationController
    def create
      if @user.authenticate(params[:password])
        create_token_and_set_header # Create JWT token and refresh token
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
      @user = User.find_by(email: params[:login].downcase.strip) if params[:email].present?
      render_error(422, 'Invalid login credentials') unless @user
    end
  end
end
