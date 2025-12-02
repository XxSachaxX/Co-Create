class User < ApplicationRecord
  include Uuidable
  has_secure_password

  has_many :project_memberships, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :projects, through: :project_memberships

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
