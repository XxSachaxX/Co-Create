class User < ApplicationRecord
  before_create :set_uuid

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :projects, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  private

  def set_uuid
    self.id ||= SecureRandom.uuid
  end
end
