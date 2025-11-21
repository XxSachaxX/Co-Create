class Project < ApplicationRecord
  include Uuidable
  belongs_to :user, required: true
  validates :description, presence: true, length: { minimum: 50 }
  validates :name, presence: true
end
