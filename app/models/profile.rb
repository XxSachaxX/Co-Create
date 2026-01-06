class Profile < ApplicationRecord
  include Uuidable

  belongs_to :user

  has_many :profile_skills, dependent: :destroy
  has_many :skills, through: :profile_skills

  has_many :profile_interests, dependent: :destroy
  has_many :interests, through: :profile_interests

  validates :description, length: { maximum: 1000 }, allow_blank: true
end
