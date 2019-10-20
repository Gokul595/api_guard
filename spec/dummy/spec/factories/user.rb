# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email 'user@api_guard.com'
    password 'api_pass'
    password_confirmation 'api_pass'
  end

  factory :user_1, class: User do
    email 'user_1@api_guard.com'
    password 'api_pass'
    password_confirmation 'api_pass'
  end
end
