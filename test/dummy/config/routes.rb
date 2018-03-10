Rails.application.routes.draw do

  mount RabbitApi::Engine => "/rabbit_api"
end
