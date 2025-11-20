class Session < ApplicationRecord
  before_create :set_uuid

  belongs_to :user

  private

  def set_uuid
    self.id ||= SecureRandom.uuid
  end
end
