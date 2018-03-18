Rails.application.routes.draw do
  rabbit_api_routes for: 'users'

  rabbit_api_routes for: 'admins', module: 'admins', path: 'admins'
end
