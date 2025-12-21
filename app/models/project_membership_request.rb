class ProjectMembershipRequest < ApplicationRecord
  include Uuidable
  scope :pending, -> { where(status: ProjectMembership::PENDING) }

  belongs_to :project
  belongs_to :user

  STATUSES =  [
    PENDING = "pending",
    ACCEPTED = "accepted"
  ]
end
