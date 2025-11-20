class Project < ApplicationRecord
  belongs_to :user, required: true
end
