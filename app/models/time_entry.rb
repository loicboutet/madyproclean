class TimeEntry < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :site
  belongs_to :corrected_by, class_name: 'User', optional: true

  # Enums
  enum :status, { active: 'active', completed: 'completed', anomaly: 'anomaly' }, default: 'active'

  # Validations
  validates :user_id, presence: true
  validates :site_id, presence: true
  validates :clocked_in_at, presence: true
  validates :status, presence: true
  validate :clocked_out_after_clocked_in
  validate :no_multiple_active_entries

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :anomalies, -> { where(status: 'anomaly') }
  scope :for_date, ->(date) { where('DATE(clocked_in_at) = ?', date) }
  scope :for_date_range, ->(start_date, end_date) { where(clocked_in_at: start_date.beginning_of_day..end_date.end_of_day) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_site, ->(site) { where(site: site) }
  scope :recent, -> { order(clocked_in_at: :desc) }
  scope :over_24_hours, -> { active.where('clocked_in_at < ?', 24.hours.ago) }

  # Callbacks
  before_save :calculate_duration, if: :clocked_out_at_changed?
  after_save :detect_anomaly

  # Methods
  def clock_out!(time = Time.current)
    self.clocked_out_at = time
    self.status = 'completed'
    calculate_duration
    save!
  end

  def calculate_duration
    if clocked_in_at && clocked_out_at
      self.duration_minutes = ((clocked_out_at - clocked_in_at) / 60).to_i
    end
  end

  def detect_anomaly
    # Check for entries over 24 hours without clock-out
    if active? && clocked_in_at && clocked_in_at < 24.hours.ago
      mark_as_anomaly("Entry has been active for more than 24 hours")
    end
  end

  def mark_as_anomaly(reason)
    update_columns(
      status: 'anomaly',
      notes: [notes, reason].compact.join('. ')
    )
  end

  def correct(admin, attributes)
    attributes[:manually_corrected] = true
    attributes[:corrected_by] = admin
    attributes[:corrected_at] = Time.current
    update(attributes)
  end

  private

  def clocked_out_after_clocked_in
    if clocked_out_at.present? && clocked_in_at.present? && clocked_out_at <= clocked_in_at
      errors.add(:clocked_out_at, "must be after clock-in time")
    end
  end

  def no_multiple_active_entries
    if active? && user_id.present?
      existing = TimeEntry.active.where(user_id: user_id).where.not(id: id)
      if existing.exists?
        errors.add(:base, "User already has an active time entry")
      end
    end
  end
end
