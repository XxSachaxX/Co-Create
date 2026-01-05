FactoryBot.define do
  factory :project do
    name { Faker::Lorem.word }
    description { "A very long description that exceeds the maximum length" }

    trait :with_tags do
      transient do
        tag_count { 3 }
      end

      after(:create) do |project, evaluator|
        FactoryBot.create_list(:tag, evaluator.tag_count).each do |tag|
          project.tags << tag
        end
      end
    end
  end
end
