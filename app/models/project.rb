class Project < ApplicationRecord
  include Uuidable
  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships, dependent: :destroy

  accepts_nested_attributes_for :project_memberships

  validates :description, presence: true, length: { minimum: 50 }
  validates :name, presence: true, length: { minimum: 1 }

  def owner
    project_memberships.find_by(role: "owner").user
  end
end
