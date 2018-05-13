require_dependency 'rabbit_api/application_controller'

module Customers
  class PasswordsController < RabbitApi::PasswordsController
    skip_before_action :authenticate_resource, only: [:update]
    before_action :authenticate_and_set_user, only: [:update]

    def update
      super
    end
  end
end
