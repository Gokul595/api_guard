module RabbitApi
  class ApplicationController < ActionController::Base
    include RabbitApi::Modules
  end
end
