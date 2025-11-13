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
    time_entries.active.includes(:user).map(&:user)
  end

  def current_time_entries
    # Returns active time entries with user information
    time_entries.active.includes(:user).order(clocked_in_at: :desc)
  end

  def current_agent_count
    time_entries.active.count
  end

  def self.with_current_occupancy
    # Efficiently loads all sites with their current occupancy data
    includes(time_entries: :user)
      .left_joins(:time_entries)
      .where('time_entries.status = ? OR time_entries.id IS NULL', 'active')
      .group('sites.id')
      .select('sites.*, COUNT(CASE WHEN time_entries.status = ? THEN 1 END) as agents_count', 'active')
      .order(:name)
  end

  private

  def generate_qr_code_token
    self.qr_code_token ||= SecureRandom.urlsafe_base64(32)
  end
end
