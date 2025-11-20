class Session < ApplicationRecord
  include Uuidable

  belongs_to :user
end
