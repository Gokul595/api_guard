FactoryBot.define do
  factory :user do
    email 'user@api_guard.com'
    password 'api_pass'
    password_confirmation 'api_pass'
  end
end
