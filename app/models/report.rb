class Report < ApplicationRecord
  # Associations
  belongs_to :generated_by, class_name: 'User', foreign_key: 'generated_by_id', optional: true
  
  # Validations
  validates :title, presence: true
  validates :report_type, presence: true
  validates :status, presence: true
  
  # Scopes
  scope :by_type, ->(type) { where(report_type: type) }
  scope :by_status, ->(status) { where(status: status) }
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :generating, -> { where(status: 'generating') }
  scope :recent, -> { order(generated_at: :desc) }
  
  # Constants for report types
  REPORT_TYPES = %w[
    monthly
    hr
    time_tracking
    scheduling
    anomalies
    payroll_export
    site_performance
    agent_performance
  ].freeze
  
  STATUSES = %w[pending generating completed failed].freeze
  
  FILE_FORMATS = %w[PDF Excel CSV HTML].freeze
  
  # Serialize filters_applied as JSON
  serialize :filters_applied, coder: JSON
end
