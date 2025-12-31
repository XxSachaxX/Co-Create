class Project < ApplicationRecord
  include Uuidable
  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships
  has_many :project_membership_requests, dependent: :destroy

  accepts_nested_attributes_for :project_memberships

  validates :description, presence: true, length: { minimum: 50 }
  validates :name, presence: true, length: { minimum: 1 }

  def owner
    project_memberships.find_by(role: ProjectMembership::OWNER).user
  end

  def owner?(user)
    owner == user
  end

  def collaborator?(user)
    return false if requested_membership?(user)
    return false if revoked_membership?(user)

    users.include?(user) && !owner?(user)
  end

  def requested_membership?(user)
    project_membership_requests.find_by(user: user, status: ProjectMembershipRequest::PENDING).present?
  end

  def revoked_membership?(user)
    project_memberships.find_by(user: user, status: ProjectMembership::REVOKED).present?
  end

  def create_membership!(user)
    project_memberships.create!(role: ProjectMembership::MEMBER, user: user, status: ProjectMembership::ACTIVE)
  end
end
