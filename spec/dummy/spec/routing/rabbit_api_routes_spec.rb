require 'dummy/spec/rails_helper'

describe 'RabbitApiRoutesSpec', type: :routing do
  describe 'generate all routes for specified resource' do
    it 'should create routes for admin' do
      Rails.application.routes.draw do
        rabbit_api_routes for: 'admins'
      end

      expect(post: "/admins/sign_up").to route_to('rabbit_api/registration#create')
      expect(delete: "/admins/sign_down").to route_to('rabbit_api/registration#destroy')

      expect(post: "/admins/sign_in").to route_to('rabbit_api/authentication#create')
      expect(delete: "/admins/sign_out").to route_to('rabbit_api/authentication#destroy')
    end
  end

  describe 'override class name' do
    it 'should create routes for customers with class User' do
      Rails.application.routes.draw do
        rabbit_api_routes for: 'customers', class_name: 'User'
      end

      expect(post: "/customers/sign_up").to route_to('rabbit_api/registration#create')
      expect(delete: "/customers/sign_down").to route_to('rabbit_api/registration#destroy')

      expect(post: "/customers/sign_in").to route_to('rabbit_api/authentication#create')
      expect(delete: "/customers/sign_out").to route_to('rabbit_api/authentication#destroy')
    end
  end

  describe 'override route helper name prefix' do
    it 'should create routes for users with helper name prefix "customer"' do
      Rails.application.routes.draw do
        rabbit_api_routes for: 'users', as: 'customer'
      end

      expect(customer_sign_up_path).to eq('/users/sign_up')
      expect(customer_sign_down_path).to eq('/users/sign_down')

      expect(customer_sign_in_path).to eq('/users/sign_in')
      expect(customer_sign_out_path).to eq('/users/sign_out')
    end
  end

  describe 'override path prefix' do
    it 'should create routes for users with path prefix customers' do
      Rails.application.routes.draw do
        rabbit_api_routes for: 'users', path: 'customers'
      end

      expect(post: "/customers/sign_up").to route_to('rabbit_api/registration#create')
      expect(delete: "/customers/sign_down").to route_to('rabbit_api/registration#destroy')

      expect(post: "/customers/sign_in").to route_to('rabbit_api/authentication#create')
      expect(delete: "/customers/sign_out").to route_to('rabbit_api/authentication#destroy')
    end

    it 'should create routes for users with no path prefix' do
      Rails.application.routes.draw do
        rabbit_api_routes for: 'users', path: ''
      end

      expect(post: "/sign_up").to route_to('rabbit_api/registration#create')
      expect(delete: "/sign_down").to route_to('rabbit_api/registration#destroy')

      expect(post: "/sign_in").to route_to('rabbit_api/authentication#create')
      expect(delete: "/sign_out").to route_to('rabbit_api/authentication#destroy')
    end
  end

  describe 'override controller' do
    it 'should create registration routes for admins with custom controller' do
      Rails.application.routes.draw do
        rabbit_api_routes for: 'admins', controller: {
          registration: 'admins/registration',
          authentication: 'admins/auth'
        }
      end

      expect(post: "/admins/sign_up").to route_to('admins/registration#create')
      expect(delete: "/admins/sign_down").to route_to('admins/registration#destroy')

      expect(post: "/admins/sign_in").to route_to('admins/auth#create')
      expect(delete: "/admins/sign_out").to route_to('admins/auth#destroy')
    end
  end
end
