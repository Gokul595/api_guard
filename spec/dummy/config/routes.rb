# frozen_string_literal: true

Rails.application.routes.draw do
  api_guard_routes for: 'users'

  api_guard_routes for: 'admins', controller: {
    registration: 'admins/registration',
    authentication: 'admins/auth'
  }

  namespace :admins do
    resources :posts, only: [:update]
  end

  api_guard_routes for: 'users', path: 'customers', as: 'customer', except: %i[registration], controller: {
    authentication: 'customers/authentication',
    tokens: 'customers/tokens',
    passwords: 'customers/passwords'
  }

  api_guard_scope 'users' do
    namespace 'customers', as: 'customer' do
      post 'create' => 'registration#create'
      delete 'delete' => 'registration#destroy'
    end
  end

  resources :posts, only: [:index]
end
