class Interest < ApplicationRecord
  include Uuidable

  # Associations
  has_many :profile_interests, dependent: :destroy
  has_many :profiles, through: :profile_interests

  # Validations
  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { minimum: 2, maximum: 50 }
  validates :name, format: {
    with: /\A[a-z0-9\-]+\z/,
    message: "must be lowercase alphanumeric with hyphens only"
  }

  before_validation :normalize_name

  private

  def normalize_name
    return unless name.present?
    self.name = name.strip.downcase.gsub(/\s+/, "-")
  end
end
