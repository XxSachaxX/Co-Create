FactoryBot.define do
  factory :user do
    name { Faker::Name.name}
    email_address { Faker::Internet.email }
    password { "password" }
  end
end
