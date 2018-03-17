RabbitApi::Engine.routes.draw do
  post 'login' => 'authentication#create'
  delete 'logout' => 'authentication#destroy'

  post 'sign_up' => 'registration#create'
  delete 'sign_down' => 'registration#destroy'  # TODO: Change this dummy route path
end
