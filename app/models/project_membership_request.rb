class ProjectMembershipRequest < ApplicationRecord
  include Uuidable

  belongs_to :project
  belongs_to :user
end
