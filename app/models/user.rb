class User < ApplicationRecord
  include Uuidable
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_and_belongs_to_many :projects, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
