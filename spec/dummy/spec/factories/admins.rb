FactoryBot.define do
  factory :admin do
    email 'admin@rabbitapi.com'
    password 'rabbit_pass'
    password_confirmation 'rabbit_pass'
  end
end
