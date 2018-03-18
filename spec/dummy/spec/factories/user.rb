FactoryBot.define do
  factory :user do
    email 'user@rabbitapi.com'
    password 'rabbit_pass'
    password_confirmation 'rabbit_pass'
  end
end
