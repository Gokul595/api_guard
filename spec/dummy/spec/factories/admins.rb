# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    email 'admin@api_guard.com'
    password 'api_pass'
    password_confirmation 'api_pass'
  end
end
