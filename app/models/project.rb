class Project < ApplicationRecord
  belongs_to :user, as: :creator
end
