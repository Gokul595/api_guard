# frozen_string_literal: true

module Customers
  class PasswordsController < ApiGuard::PasswordsController
    skip_before_action :authenticate_resource, only: [:update]
    before_action :authenticate_and_set_user, only: [:update]

    def update
      super
    end
  end
end
