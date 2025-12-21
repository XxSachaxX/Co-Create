FactoryBot.define do
  factory :project_membership do
    user { user }
    project { project }
    role { role }
  end
end
