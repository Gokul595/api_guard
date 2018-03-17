require_dependency "rabbit_api/application_controller"

module RabbitApi
  class RegistrationController < ApplicationController
    def create
      @user = User.new(users_params)
      if @user.save
        create_token_and_set_header
        render_success(data: @user, message: 'User created successfully')
      else
        render_error(422, object: @user)
      end
    end

    def destroy
      @user.destroy
      render_success(message: 'User destroyed successfully')
    end

    private

    def users_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
  end
end
