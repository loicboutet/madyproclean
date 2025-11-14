class Absence < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :created_by, class_name: 'User'

  # Enums
  enum :absence_type, {
    vacation: 'vacation',      # Congés
    sick: 'sick',             # Maladie
    training: 'training',     # Formation
    other: 'other'            # Autre
  }, default: 'vacation'

  enum :status, {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }, default: 'pending'

  # Validations
  validates :absence_type, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, presence: true
  validate :end_date_after_start_date

  # Scopes
  scope :upcoming, -> { where('end_date >= ?', Date.current).order(:start_date) }
  scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :past, -> { where('end_date < ?', Date.current).order(start_date: :desc) }
  scope :by_type, ->(type) { where(absence_type: type) }
  scope :by_status, ->(status) { where(status: status) }

  # Instance methods
  def duration_days
    return 0 unless start_date && end_date
    (end_date - start_date).to_i + 1
  end

  def active?
    start_date <= Date.current && end_date >= Date.current
  end

  def type_badge_class
    case absence_type
    when 'vacation'
      'badge-success'
    when 'sick'
      'badge-warning'
    when 'training'
      'badge'
    else
      'badge-secondary'
    end
  end

  def type_label
    case absence_type
    when 'vacation'
      'Congés'
    when 'sick'
      'Maladie'
    when 'training'
      'Formation'
    else
      'Autre'
    end
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, 'must be after the start date')
    end
  end
end
