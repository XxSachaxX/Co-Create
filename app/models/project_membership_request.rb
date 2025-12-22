class ProjectMembershipRequest < ApplicationRecord
  include Uuidable
  scope :pending, -> { where(status: ProjectMembership::PENDING) }

  belongs_to :project
  belongs_to :user

  STATUSES =  [
    PENDING = "pending",
    ACCEPTED = "accepted",
    REJECTED = "rejected"
  ].freeze

  def accept!
    update(status: ProjectMembershipRequest::ACCEPTED)
  end

  def reject!
    update(status: ProjectMembershipRequest::REJECTED)
  end
end
