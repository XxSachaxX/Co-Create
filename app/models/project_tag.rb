class ProjectTag < ApplicationRecord
  include Uuidable

  belongs_to :tag, counter_cache: :projects_count
  belongs_to :project

  validates :tag_id, uniqueness: { scope: :project_id }
end
