FactoryBot.define do
  factory :project_tag do
    association :project
    association :tag
  end
end
