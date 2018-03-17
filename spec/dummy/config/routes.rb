Rails.application.routes.draw do
  mount RabbitApi::Engine => "/users", resource_class: 'User', as: 'api_user'
end
