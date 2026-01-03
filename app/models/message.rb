class Message < ApplicationRecord
  include Uuidable
  belongs_to :user
  belongs_to :project
  validates :content, presence: true

  scope :from_most_recent, -> { includes(:user).order(created_at: :asc) }
end
