class TimeEntry < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :site
  belongs_to :corrected_by, class_name: 'User', optional: true
  has_many :anomaly_logs, dependent: :nullify

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
    return unless saved_change_to_clocked_in_at? || saved_change_to_clocked_out_at? || saved_change_to_status?
    
    # Check for entries over 24 hours without clock-out
    if active? && clocked_in_at && clocked_in_at < 24.hours.ago
      # Only create anomaly if one doesn't already exist for this entry
      unless anomaly_logs.anomaly_type_over_24h.exists?
        AnomalyLog.create_for_over_24h(self)
        mark_as_anomaly_status
      end
    end
  end

  def mark_as_anomaly_status
    update_columns(status: 'anomaly') unless anomaly?
  end

  # Check for missed clock-out (called externally, e.g., from a scheduled job)
  def self.detect_missed_clock_outs
    # Find active entries from yesterday that should have been clocked out
    yesterday_active = active.where('DATE(clocked_in_at) < ?', Date.current)
    
    yesterday_active.find_each do |entry|
      # Only create anomaly if one doesn't already exist
      unless entry.anomaly_logs.anomaly_type_missed_clock_out.exists?
        AnomalyLog.create_for_missed_clock_out(entry)
        entry.mark_as_anomaly_status
      end
    end
  end

  # Detect multiple active entries for the same user (fraud detection)
  def self.detect_multiple_active_entries
    User.find_each do |user|
      active_entries = user.time_entries.active
      if active_entries.count > 1
        # Check if they have different IP addresses (fraud indicator)
        ip_addresses = active_entries.pluck(:ip_address_in).compact.uniq
        if ip_addresses.count > 1
          # Only create anomaly if one doesn't already exist
          unless AnomalyLog.anomaly_type_multiple_active.for_user(user).unresolved.exists?
            AnomalyLog.create_for_multiple_active(user, active_entries)
            active_entries.each(&:mark_as_anomaly_status)
          end
        end
      end
    end
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
