class Project < ApplicationRecord
  include Uuidable
  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships, dependent: :destroy
  validates :description, presence: true, length: { minimum: 50 }
  validates :name, presence: true, length: { minimum: 1 }
end
