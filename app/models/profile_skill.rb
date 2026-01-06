class ProfileSkill < ApplicationRecord
  include Uuidable

  belongs_to :profile
  belongs_to :skill

  validates :profile_id, uniqueness: { scope: :skill_id }
end
