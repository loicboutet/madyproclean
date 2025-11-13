class Schedule < ApplicationRecord
  # Enums
  enum :status, { scheduled: 'scheduled', completed: 'completed', missed: 'missed', cancelled: 'cancelled' }, default: 'scheduled'

  # Associations
  belongs_to :user
  belongs_to :site
  belongs_to :created_by, class_name: 'User'
  belongs_to :replaced_by, class_name: 'User', optional: true

  # Validations
  validates :user_id, presence: true
  validates :site_id, presence: true
  validates :scheduled_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true
  validates :created_by_id, presence: true
  
  validate :end_time_after_start_time
  validate :no_overlapping_schedules, on: :create

  # Scopes
  scope :for_date, ->(date) { where(scheduled_date: date) }
  scope :for_date_range, ->(start_date, end_date) { where(scheduled_date: start_date..end_date) }
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :for_site, ->(site) { where(site_id: site.id) }
  scope :upcoming, -> { where('scheduled_date >= ?', Date.current) }
  scope :past, -> { where('scheduled_date < ?', Date.current) }
  scope :by_date, -> { order(scheduled_date: :asc) }
  scope :recent, -> { order(scheduled_date: :desc) }

  # Instance methods
  def check_completion
    # Check if there's a time entry for this schedule
    time_entry = TimeEntry.where(
      user_id: user_id,
      site_id: site_id
    ).where('DATE(clocked_in_at) = ?', scheduled_date).first

    if time_entry
      update(status: 'completed') if scheduled?
      true
    else
      false
    end
  end

  def mark_as_missed
    update(status: 'missed') if scheduled?
  end

  def mark_as_completed
    update(status: 'completed') if scheduled?
  end

  def assign_replacement(new_agent, reason)
    update(replaced_by: new_agent, replacement_reason: reason)
  end

  def time_entry_exists?
    TimeEntry.exists?(
      user_id: user_id,
      site_id: site_id,
      clocked_in_at: scheduled_date.beginning_of_day..scheduled_date.end_of_day
    )
  end

  def duration_hours
    return 0 unless start_time && end_time
    ((end_time - start_time) / 3600.0).round(2)
  end

  private

  def end_time_after_start_time
    if start_time.present? && end_time.present? && end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def no_overlapping_schedules
    return unless user_id && scheduled_date && start_time && end_time

    overlapping = Schedule.where(user_id: user_id, scheduled_date: scheduled_date)
                         .where.not(id: id)
                         .where("(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)",
                                end_time, start_time, end_time, end_time, start_time, end_time)

    if overlapping.exists?
      errors.add(:base, "User already has a schedule that overlaps with this time period")
    end
  end
end
