FactoryBot.define do
  factory :project_membership_request do
    user { user }
    project { project }
    status { "pending" }
  end
end
