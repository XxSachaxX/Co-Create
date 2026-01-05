class Project < ApplicationRecord
  include Uuidable
  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships
  has_many :project_membership_requests, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :project_tags, dependent: :destroy
  has_many :tags, through: :project_tags

  accepts_nested_attributes_for :project_memberships

  validates :description, presence: true, length: { minimum: 50 }
  validates :name, presence: true, length: { minimum: 1 }
  validate :validate_tag_limit

  # Scopes
  scope :with_any_tags, ->(tag_names) {
    return all if tag_names.blank?

    joins(:tags)
      .where(tags: { name: tag_names })
      .group("projects.id")
      .distinct
  }

  scope :with_all_tags, ->(tag_names) {
    return all if tag_names.blank?

    joins(:tags)
      .where(tags: { name: tag_names })
      .group("projects.id")
      .having("COUNT(DISTINCT tags.id) = ?", tag_names.size)
      .distinct
  }

  def owner
    project_memberships.find_by(role: ProjectMembership::OWNER).user
  end

  def owner?(user)
    owner == user
  end

  def collaborator?(user)
    return true if active_membership?(user)
    return false if revoked_membership?(user)
    return false if requested_membership?(user)

    users.include?(user) && !owner?(user)
  end

  def requested_membership?(user)
    project_membership_requests.find_by(user: user, status: ProjectMembershipRequest::PENDING).present?
  end

  def revoked_membership?(user)
    project_memberships.find_by(user: user, status: ProjectMembership::REVOKED).present?
  end

  def active_membership?(user)
    project_memberships.find_by(user: user, status: ProjectMembership::ACTIVE).present?
  end

  def create_membership!(user)
    project_memberships.create!(role: ProjectMembership::MEMBER, user: user, status: ProjectMembership::ACTIVE)
  end

  # Tag management methods

  # Returns array of tag names: ["rails", "saas"]
  def tag_list
    tags.pluck(:name)
  end

  # Accepts array of tag names: ["Rails", "SaaS"]
  # Creates tags if they don't exist, assigns to project
  def tag_list=(names)
    names = Array(names).compact_blank.map { |n| n.to_s.strip.downcase }

    self.tags = names.uniq.map do |name|
      Tag.find_or_create_by!(name: name)
    end
  end

  # Returns comma-separated string: "rails, saas"
  # Used for displaying in text inputs
  def tag_names
    tag_list.join(", ")
  end

  # Accepts comma-separated string: "Rails, SaaS"
  # Used for processing form input
  def tag_names=(string)
    if string.blank?
      self.tag_list = []
    else
      self.tag_list = string.split(",")
    end
  end

  private

  def validate_tag_limit
    if tags.size > 10
      errors.add(:tag_list, "maximum 10 tags allowed")
    end
  end
end
