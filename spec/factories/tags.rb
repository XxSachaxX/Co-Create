FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "tag#{n}" }
    projects_count { 0 }
  end
end
