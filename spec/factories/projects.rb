FactoryBot.define do
  factory :project do
    name { Faker::Lorem.word }
    description { "A very long description that exceeds the maximum length" }
  end
end
