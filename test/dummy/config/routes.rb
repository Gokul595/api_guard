Rails.application.routes.draw do
  mount RabbitApi::Engine => "/"
end
