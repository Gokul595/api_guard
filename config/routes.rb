RabbitApi::Engine.routes.draw do
  resources :users, only: [:create, :destroy]
end
