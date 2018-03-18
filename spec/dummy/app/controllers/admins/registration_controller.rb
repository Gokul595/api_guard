module Admins
  class RegistrationController < RabbitApi::RegistrationController
    def create
      super
    end

    def destroy
      super
    end

    private

    # def sign_up_params
    #   params.require(resource_class_name.downcase.to_sym).permit(:email, :password, :password_confirmation)
    # end
  end
end
