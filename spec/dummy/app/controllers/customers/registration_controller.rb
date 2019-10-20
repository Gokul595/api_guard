# frozen_string_literal: true

module Customers
  class RegistrationController < ApiGuard::RegistrationController
    skip_before_action :authenticate_resource, only: [:destroy]
    before_action :authenticate_and_set_user, only: [:destroy]

    def create
      super
    end

    def destroy
      current_user.destroy
      render_success(message: 'Customer destroyed successfully')
    end

    private

    def sign_up_params
      params.require(:customer).permit(:email, :password, :password_confirmation)
    end
  end
end
