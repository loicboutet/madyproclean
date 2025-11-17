class AnomalyLog < ApplicationRecord
  # Enums
  enum :anomaly_type, {
    missed_clock_in: 'missed_clock_in',
    missed_clock_out: 'missed_clock_out',
    over_24h: 'over_24h',
    multiple_active: 'multiple_active',
    schedule_mismatch: 'schedule_mismatch'
  }, prefix: true

  enum :severity, {
    low: 'low',
    medium: 'medium',
    high: 'high'
  }, prefix: true

  # Associations
  belongs_to :user, optional: true
  belongs_to :time_entry, optional: true
  belongs_to :schedule, optional: true
  belongs_to :resolved_by, class_name: 'User', optional: true

  # Validations
  validates :anomaly_type, presence: true
  validates :description, presence: true
  validates :severity, presence: true

  # Scopes
  scope :unresolved, -> { where(resolved: false) }
  scope :resolved, -> { where(resolved: true) }
  scope :by_severity, ->(severity) { where(severity: severity) if severity.present? }
  scope :by_type, ->(type) { where(anomaly_type: type) if type.present? }
  scope :for_user, ->(user) { where(user: user) if user.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_date, ->(date) { where('DATE(created_at) = ?', date) if date.present? }

  # Instance Methods
  def resolve!(admin, notes = nil)
    update!(
      resolved: true,
      resolved_by: admin,
      resolved_at: Time.current,
      resolution_notes: notes
    )
  end

  # Class Methods
  def self.create_for_missed_clock_out(time_entry)
    create!(
      anomaly_type: :missed_clock_out,
      severity: :medium,
      user: time_entry.user,
      time_entry: time_entry,
      description: "Agent n'a pas enregistré sa sortie du site #{time_entry.site.name} le #{time_entry.clocked_in_at.strftime('%d/%m/%Y')}"
    )
  end

  def self.create_for_over_24h(time_entry)
    hours = ((Time.current - time_entry.clocked_in_at) / 1.hour).round
    create!(
      anomaly_type: :over_24h,
      severity: :high,
      user: time_entry.user,
      time_entry: time_entry,
      description: "Pointage actif depuis plus de 24 heures (#{hours}h) sur le site #{time_entry.site.name}"
    )
  end

  def self.create_for_schedule_mismatch(schedule)
    create!(
      anomaly_type: :schedule_mismatch,
      severity: :medium,
      user: schedule.user,
      schedule: schedule,
      description: "Agent n'a pas pointé alors qu'il était planifié sur le site #{schedule.site.name} le #{schedule.scheduled_date.strftime('%d/%m/%Y')}"
    )
  end

  def self.create_for_missed_clock_in(schedule)
    create!(
      anomaly_type: :missed_clock_in,
      severity: :low,
      user: schedule.user,
      schedule: schedule,
      description: "Aucun pointage d'entrée enregistré pour l'horaire planifié du #{schedule.scheduled_date.strftime('%d/%m/%Y')}"
    )
  end

  def self.create_for_multiple_active(user, time_entries)
    create!(
      anomaly_type: :multiple_active,
      severity: :high,
      user: user,
      time_entry: time_entries.first,
      description: "Détection de plusieurs pointages actifs simultanés depuis des adresses IP différentes"
    )
  end

  # Helper method to get human-readable type
  def type_label
    case anomaly_type
    when 'missed_clock_in'
      '📥 Entrée manquante'
    when 'missed_clock_out'
      '📤 Sortie manquante'
    when 'over_24h'
      '⏱️ Plus de 24h'
    when 'multiple_active'
      '🔄 Pointages multiples'
    when 'schedule_mismatch'
      '📅 Désaccord horaire'
    end
  end

  # Helper method to get severity badge
  def severity_label
    case severity
    when 'low'
      '🔵 Faible'
    when 'medium'
      '🟡 Moyenne'
    when 'high'
      '🔴 Haute'
    end
  end
end
