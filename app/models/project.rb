class Project < ApplicationRecord
  before_create :set_uuid
  belongs_to :user, required: true

  private

  def set_uuid
    self.id ||= SecureRandom.uuid
  end
end
