class Site < ApplicationRecord
  # Associations
  has_many :time_entries, dependent: :destroy
  has_many :schedules, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9\-]+\z/, message: "must be alphanumeric (dashes allowed)" }
  validates :qr_code_token, presence: true, uniqueness: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :alphabetical, -> { order(:name) }

  # Callbacks
  before_validation :generate_qr_code_token, on: :create

  # Methods
  def qr_code_url
    # This would generate the full URL for QR code scanning
    # For now, return a placeholder
    "#{Rails.application.routes.url_helpers.root_url}clock/#{qr_code_token}"
  end

  def current_agents
    # Returns agents currently on site (active time entries)
    time_entries.joins(:user).where(status: 'active').map(&:user)
  end

  private

  def generate_qr_code_token
    self.qr_code_token ||= SecureRandom.urlsafe_base64(32)
  end
end
