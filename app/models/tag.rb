class Tag < ApplicationRecord
  include Uuidable

  # Associations
  has_many :project_tags, dependent: :destroy
  has_many :projects, through: :project_tags

  # Validations
  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { minimum: 2, maximum: 30 }
  validates :name, format: {
    with: /\A[a-z0-9\-]+\z/,
    message: "must be lowercase alphanumeric with hyphens only"
  }

  # Callbacks
  before_validation :normalize_name

  # Scopes
  scope :popular, -> { order(projects_count: :desc) }
  scope :alphabetical, -> { order(name: :asc) }
  scope :search, ->(query) {
    where("name LIKE ?", "%#{sanitize_sql_like(query.downcase)}%") if query.present?
  }

  # Instance methods
  def to_param
    name.parameterize
  end

  private

  def normalize_name
    return unless name.present?
    self.name = name.strip.downcase.gsub(/\s+/, "-")
  end
end
