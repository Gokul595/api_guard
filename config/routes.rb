RabbitApi::Engine.routes.draw do
  post 'login' => 'authentication#create'
  delete 'logout' => 'authentication#destroy'

  resources :registration, only: [:create, :destroy]
end
