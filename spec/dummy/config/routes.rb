Rails.application.routes.draw do
  api_guard_routes for: 'users'

  api_guard_routes for: 'customers', class_name: 'User', controller: {
    authentication: 'customers/authentication',
    tokens: 'customers/tokens',
    passwords: 'customers/passwords'
  }

  api_guard_routes for: 'admins', controller: {
    registration: 'admins/registration',
    authentication: 'admins/auth'
  }
end
