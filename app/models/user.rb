class User < ApplicationRecord
  include Uuidable
  has_secure_password

  has_many :project_memberships, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :project_membership_requests, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_one :profile, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
