RabbitApi::Engine.routes.draw do
  post 'login' => 'authentication#create'
  delete 'logout' => 'authentication#destroy'

  resources :users, only: [:create, :destroy]
end
