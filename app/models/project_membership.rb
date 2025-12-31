class ProjectMembership < ApplicationRecord
  include Uuidable
  belongs_to :project
  belongs_to :user

  STATUSES = [
    ACTIVE = "active",
    REVOKED = "revoked"
  ]

  ROLES =  [
    OWNER = "owner",
    MEMBER = "member"
  ]

  def revoke!
    update(status: REVOKED)
  end
end
