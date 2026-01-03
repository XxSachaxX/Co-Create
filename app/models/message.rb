class Message < ApplicationRecord
  include Uuidable
  belongs_to :user
  belongs_to :project
  validates :content, presence: true
end
