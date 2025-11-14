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
  
  # Constants for report types (WHAT to report)
  REPORT_TYPES = %w[
    hr
    time_tracking
    scheduling
    anomalies
    payroll_export
    site_performance
    agent_performance
  ].freeze
  
  # Constants for period types (WHEN to report)
  PERIOD_TYPES = %w[
    monthly
    weekly
    quarterly
    yearly
    custom
  ].freeze
  
  STATUSES = %w[pending generating completed failed].freeze
  
  FILE_FORMATS = %w[PDF Excel CSV HTML].freeze
  
  # Serialize filters_applied as JSON
  serialize :filters_applied, coder: JSON
  
  # Calculate metrics on-demand based on report_type and filters_applied
  def total_hours
    return @total_hours if defined?(@total_hours)
    @total_hours = calculate_total_hours
  end
  
  def total_agents
    return @total_agents if defined?(@total_agents)
    @total_agents = calculate_total_agents
  end
  
  def total_sites
    return @total_sites if defined?(@total_sites)
    @total_sites = calculate_total_sites
  end
  
  # HR-specific metrics
  def total_absences
    return nil unless report_type == 'hr'
    # TODO: Calculate from User/Absence models based on filters_applied
    0
  end
  
  def absence_rate
    return nil unless report_type == 'hr'
    # TODO: Calculate from User/Absence models based on filters_applied
    0.0
  end
  
  def coverage_rate
    return nil unless report_type == 'hr'
    # TODO: Calculate from Schedule/User models based on filters_applied
    0.0
  end
  
  # Anomaly-specific metrics
  def total_anomalies
    return nil unless report_type == 'anomalies'
    return @total_anomalies if defined?(@total_anomalies)
    @total_anomalies = calculate_total_anomalies
  end
  
  def resolved_anomalies
    return nil unless report_type == 'anomalies'
    return @resolved_anomalies if defined?(@resolved_anomalies)
    @resolved_anomalies = calculate_resolved_anomalies
  end
  
  def unresolved_anomalies
    return nil unless report_type == 'anomalies'
    total = total_anomalies || 0
    resolved = resolved_anomalies || 0
    total - resolved
  end
  
  # Scheduling-specific metrics
  def total_schedules
    return nil unless report_type == 'scheduling'
    # TODO: Calculate from Schedule model based on filters_applied
    0
  end
  
  def scheduled_count
    return nil unless report_type == 'scheduling'
    # TODO: Calculate from Schedule model based on filters_applied
    0
  end
  
  def completed_count
    return nil unless report_type == 'scheduling'
    # TODO: Calculate from Schedule model based on filters_applied
    0
  end
  
  def missed_count
    return nil unless report_type == 'scheduling'
    # TODO: Calculate from Schedule model based on filters_applied
    0
  end
  
  # Site-specific info
  def site_name
    return nil unless filters_applied && filters_applied['site_id']
    Site.find_by(id: filters_applied['site_id'])&.name
  end
  
  def site_code
    return nil unless filters_applied && filters_applied['site_id']
    Site.find_by(id: filters_applied['site_id'])&.code
  end
  
  private
  
  def calculate_total_hours
    return 0.0 unless period_start && period_end
    
    time_entries = TimeEntry.for_date_range(period_start, period_end)
    time_entries = apply_filters(time_entries)
    
    total_minutes = time_entries.where.not(duration_minutes: nil).sum(:duration_minutes)
    (total_minutes / 60.0).round(2)
  end
  
  def calculate_total_agents
    return 0 unless period_start && period_end
    
    time_entries = TimeEntry.for_date_range(period_start, period_end)
    time_entries = apply_filters(time_entries)
    
    time_entries.select(:user_id).distinct.count
  end
  
  def calculate_total_sites
    return 0 unless period_start && period_end
    
    time_entries = TimeEntry.for_date_range(period_start, period_end)
    time_entries = apply_filters(time_entries)
    
    time_entries.select(:site_id).distinct.count
  end
  
  def calculate_total_anomalies
    return 0 unless period_start && period_end
    
    anomalies = AnomalyLog.where('created_at >= ? AND created_at <= ?', 
                                  period_start.beginning_of_day, 
                                  period_end.end_of_day)
    anomalies = apply_anomaly_filters(anomalies)
    anomalies.count
  end
  
  def calculate_resolved_anomalies
    return 0 unless period_start && period_end
    
    anomalies = AnomalyLog.where('created_at >= ? AND created_at <= ?', 
                                  period_start.beginning_of_day, 
                                  period_end.end_of_day)
                          .where(resolved: true)
    anomalies = apply_anomaly_filters(anomalies)
    anomalies.count
  end
  
  def apply_filters(relation)
    return relation unless filters_applied
    
    if filters_applied['user_id'].present?
      relation = relation.where(user_id: filters_applied['user_id'])
    end
    
    if filters_applied['site_id'].present?
      relation = relation.where(site_id: filters_applied['site_id'])
    end
    
    relation
  end
  
  def apply_anomaly_filters(relation)
    return relation unless filters_applied
    
    if filters_applied['user_id'].present?
      relation = relation.where(user_id: filters_applied['user_id'])
    end
    
    if filters_applied['severity'].present?
      relation = relation.where(severity: filters_applied['severity'])
    end
    
    relation
  end
end
