class Project < ApplicationRecord
  include Uuidable
  has_and_belongs_to_many :users
  validates :description, presence: true, length: { minimum: 50 }
  validates :name, presence: true, length: { minimum: 1 }
end
