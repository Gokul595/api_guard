# frozen_string_literal: true

module Customers
  class TokensController < ApiGuard::TokensController
    skip_before_action :authenticate_resource, only: [:create]
    before_action :authenticate_and_set_user, only: [:create]
    before_action :find_refresh_token, only: [:create]
  end
end
