class ProfileInterest < ApplicationRecord
  include Uuidable

  belongs_to :profile
  belongs_to :interest

  validates :profile_id, uniqueness: { scope: :interest_id }
end
