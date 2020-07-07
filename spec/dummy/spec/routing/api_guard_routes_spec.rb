# frozen_string_literal: true

require 'dummy/spec/rails_helper'

describe 'ApiGuardRoutesSpec', type: :routing do
  describe 'generate all routes for specified resource' do
    it 'should create routes for user' do
      Rails.application.routes.draw do
        api_guard_routes for: 'users'
      end

      expect(post: '/users/sign_up').to route_to('api_guard/registration#create')
      expect(delete: '/users/delete').to route_to('api_guard/registration#destroy')

      expect(post: '/users/sign_in').to route_to('api_guard/authentication#create')
      expect(delete: '/users/sign_out').to route_to('api_guard/authentication#destroy')

      expect(patch: '/users/passwords').to route_to('api_guard/passwords#update')

      expect(post: '/users/tokens').to route_to('api_guard/tokens#create')
    end

    it 'should create routes for admin' do
      Rails.application.routes.draw do
        api_guard_routes for: 'admins'
      end

      expect(post: '/admins/sign_up').to route_to('api_guard/registration#create')
      expect(delete: '/admins/delete').to route_to('api_guard/registration#destroy')

      expect(post: '/admins/sign_in').to route_to('api_guard/authentication#create')
      expect(delete: '/admins/sign_out').to route_to('api_guard/authentication#destroy')

      expect(patch: '/admins/passwords').to route_to('api_guard/passwords#update')

      expect(post: '/admins/tokens').to route_to('api_guard/tokens#create')
    end
  end

  describe 'route options' do
    context 'override route helper name prefix' do
      it 'should create routes for users with helper name prefix "customer"' do
        Rails.application.routes.draw do
          api_guard_routes for: 'users', as: 'customer'
        end

        expect(customer_sign_up_path).to eq('/users/sign_up')
        expect(customer_delete_path).to eq('/users/delete')

        expect(customer_sign_in_path).to eq('/users/sign_in')
        expect(customer_sign_out_path).to eq('/users/sign_out')

        expect(customer_passwords_path).to eq('/users/passwords')

        expect(customer_tokens_path).to eq('/users/tokens')
      end
    end

    context 'override path prefix' do
      it 'should create routes for users with path prefix customers' do
        Rails.application.routes.draw do
          api_guard_routes for: 'users', path: 'customers'
        end

        expect(post: '/customers/sign_up').to route_to('api_guard/registration#create')
        expect(delete: '/customers/delete').to route_to('api_guard/registration#destroy')

        expect(post: '/customers/sign_in').to route_to('api_guard/authentication#create')
        expect(delete: '/customers/sign_out').to route_to('api_guard/authentication#destroy')

        expect(patch: '/customers/passwords').to route_to('api_guard/passwords#update')

        expect(post: '/customers/tokens').to route_to('api_guard/tokens#create')
      end

      it 'should create routes for users with no path prefix' do
        Rails.application.routes.draw do
          api_guard_routes for: 'users', path: ''
        end

        expect(post: '/sign_up').to route_to('api_guard/registration#create')
        expect(delete: '/delete').to route_to('api_guard/registration#destroy')

        expect(post: '/sign_in').to route_to('api_guard/authentication#create')
        expect(delete: '/sign_out').to route_to('api_guard/authentication#destroy')

        expect(patch: '/passwords').to route_to('api_guard/passwords#update')

        expect(post: '/tokens').to route_to('api_guard/tokens#create')
      end
    end

    context 'override controller' do
      it 'should create registration routes for admins with custom controller' do
        Rails.application.routes.draw do
          api_guard_routes for: 'admins', controller: {
            registration: 'admins/registration',
            authentication: 'admins/auth'
          }
        end

        expect(post: '/admins/sign_up').to route_to('admins/registration#create')
        expect(delete: '/admins/delete').to route_to('admins/registration#destroy')

        expect(post: '/admins/sign_in').to route_to('admins/auth#create')
        expect(delete: '/admins/sign_out').to route_to('admins/auth#destroy')
      end
    end

    context "using 'except' & 'only'" do
      it 'should create user routes except registration & passwords controller' do
        Rails.application.routes.draw do
          api_guard_routes for: 'users', except: %i[passwords]
        end

        expect(post: '/users/sign_up').to route_to('api_guard/registration#create')
        expect(delete: '/users/delete').to route_to('api_guard/registration#destroy')

        expect(post: '/users/sign_in').to route_to('api_guard/authentication#create')
        expect(delete: '/users/sign_out').to route_to('api_guard/authentication#destroy')

        expect(patch: '/users/passwords').to_not route_to('api_guard/passwords#update')

        expect(post: '/users/tokens').to route_to('api_guard/tokens#create')
      end

      it 'should create user routes only for authentication & tokens controller' do
        Rails.application.routes.draw do
          api_guard_routes for: 'users', only: %i[authentication tokens]
        end

        expect(post: '/users/sign_up').to_not route_to('api_guard/registration#create')
        expect(delete: '/users/delete').to_not route_to('api_guard/registration#destroy')

        expect(post: '/users/sign_in').to route_to('api_guard/authentication#create')
        expect(delete: '/users/sign_out').to route_to('api_guard/authentication#destroy')

        expect(patch: '/users/passwords').to_not route_to('api_guard/passwords#update')

        expect(post: '/users/tokens').to route_to('api_guard/tokens#create')
      end
    end
  end

  describe 'using api_guard_scope' do
    it "should create routes for customers with api_guard scope 'users'" do
      Rails.application.routes.draw do
        api_guard_scope 'users' do
          namespace 'customers', as: 'customer' do
            post 'create' => 'registration#create'
            delete 'delete' => 'registration#destroy'
          end
        end
      end

      expect(post: 'customers/create').to route_to('customers/registration#create')
      expect(delete: 'customers/delete').to route_to('customers/registration#destroy')
    end

    it 'should use custom routes for registration controllers' do
      Rails.application.routes.draw do
        api_guard_routes for: 'users', except: [:registration]

        api_guard_scope 'users' do
          post 'account/create' => 'api_guard/registration#create'
          delete 'account/delete' => 'api_guard/registration#destroy'
        end
      end

      expect(post: 'account/create').to route_to('api_guard/registration#create')
      expect(delete: 'account/delete').to route_to('api_guard/registration#destroy')
    end
  end
end
