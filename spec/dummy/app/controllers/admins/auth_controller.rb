module Admins
  class AuthController < RabbitApi::RegistrationController
    before_action :find_resource, only: [:create]

    def create
      super
    end

    def destroy
      super
    end
  end
end
