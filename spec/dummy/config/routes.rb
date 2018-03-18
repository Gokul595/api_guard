Rails.application.routes.draw do
  mount RabbitApi::Engine => "/users", resource_class: 'User', as: 'user'
  mount RabbitApi::Engine => "/admins", resource_class: 'Admin', as: 'admin'
end
