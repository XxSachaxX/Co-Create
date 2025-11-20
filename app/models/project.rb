class Project < ApplicationRecord
  include Uuidable
  belongs_to :user, required: true
end
