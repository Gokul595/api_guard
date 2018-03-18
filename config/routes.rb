RabbitApi::Engine.routes.draw do
  post 'sign_in' => 'authentication#create'
  delete 'sign_out' => 'authentication#destroy'

  post 'sign_up' => 'registration#create'
  delete 'sign_down' => 'registration#destroy'  # TODO: Change this dummy route path
end
