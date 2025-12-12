class ProjectMembership < ApplicationRecord
  include Uuidable
  belongs_to :project
  belongs_to :user

  STATUSES = [
    PENDING = "pending",
    ACTIVE = "active"
  ]
end
