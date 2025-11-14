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
  
  # Configuration for report data sources and field mappings
  REPORT_DATA_SOURCES = {
    'time_tracking' => {
      model: TimeEntry,
      date_field: :clocked_in_at,
      metrics: {
        total_hours: {
          field: :duration_minutes,
          aggregate: :sum,
          transform: ->(value) { (value / 60.0).round(2) },
          condition: ->(relation) { relation.where.not(duration_minutes: nil) }
        },
        total_agents: {
          field: :user_id,
          aggregate: :count,
          distinct: true
        },
        total_sites: {
          field: :site_id,
          aggregate: :count,
          distinct: true
        }
      },
      filters: {
        user_id: ->(relation, value) { relation.where(user_id: value) },
        site_id: ->(relation, value) { relation.where(site_id: value) }
      }
    },
    'anomalies' => {
      model: AnomalyLog,
      date_field: :created_at,
      metrics: {
        total_anomalies: {
          aggregate: :count
        },
        resolved_anomalies: {
          aggregate: :count,
          condition: ->(relation) { relation.where(resolved: true) }
        }
      },
      filters: {
        user_id: ->(relation, value) { relation.where(user_id: value) },
        severity: ->(relation, value) { relation.where(severity: value) }
      }
    },
    'hr' => {
      model: User,
      date_field: nil, # HR reports may use different date logic
      metrics: {
        # Placeholder - to be implemented
      },
      filters: {}
    },
    'scheduling' => {
      model: Schedule,
      date_field: :date,
      metrics: {
        # Placeholder - to be implemented
      },
      filters: {}
    },
    'site_performance' => {
      model: TimeEntry,
      date_field: :clocked_in_at,
      metrics: {
        total_hours: {
          field: :duration_minutes,
          aggregate: :sum,
          transform: ->(value) { (value / 60.0).round(2) },
          condition: ->(relation) { relation.where.not(duration_minutes: nil) }
        },
        total_sites: {
          field: :site_id,
          aggregate: :count,
          distinct: true
        }
      },
      filters: {
        site_id: ->(relation, value) { relation.where(site_id: value) }
      }
    },
    'payroll_export' => {
      model: TimeEntry,
      date_field: :clocked_in_at,
      metrics: {
        total_hours: {
          field: :duration_minutes,
          aggregate: :sum,
          transform: ->(value) { (value / 60.0).round(2) },
          condition: ->(relation) { relation.where.not(duration_minutes: nil) }
        },
        total_agents: {
          field: :user_id,
          aggregate: :count,
          distinct: true
        }
      },
      filters: {
        user_id: ->(relation, value) { relation.where(user_id: value) }
      }
    }
  }.freeze
  
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
  
  # Generic metric calculation using configuration
  def calculate_metric(metric_name)
    config = REPORT_DATA_SOURCES[report_type]
    return 0 unless config && period_start && period_end
    
    metric_config = config[:metrics][metric_name]
    return 0 unless metric_config
    
    # Get base relation from model
    relation = config[:model].all
    
    # Apply date range filter if date_field is specified
    if config[:date_field]
      date_field = config[:date_field]
      relation = relation.where(
        "#{date_field} >= ? AND #{date_field} <= ?",
        period_start.beginning_of_day,
        period_end.end_of_day
      )
    end
    
    # Apply configured filters from filters_applied
    relation = apply_configured_filters(relation, config[:filters])
    
    # Apply metric-specific condition
    if metric_config[:condition]
      relation = metric_config[:condition].call(relation)
    end
    
    # Perform aggregation
    result = if metric_config[:field]
      if metric_config[:distinct]
        relation.select(metric_config[:field]).distinct.count
      elsif metric_config[:aggregate] == :sum
        relation.sum(metric_config[:field])
      elsif metric_config[:aggregate] == :count
        relation.count
      else
        0
      end
    else
      relation.count
    end
    
    # Apply transformation if specified
    if metric_config[:transform]
      metric_config[:transform].call(result)
    else
      result
    end
  end
  
  def calculate_total_hours
    calculate_metric(:total_hours)
  end
  
  def calculate_total_agents
    calculate_metric(:total_agents)
  end
  
  def calculate_total_sites
    calculate_metric(:total_sites)
  end
  
  def calculate_total_anomalies
    calculate_metric(:total_anomalies)
  end
  
  def calculate_resolved_anomalies
    calculate_metric(:resolved_anomalies)
  end
  
  # Apply filters using configuration
  def apply_configured_filters(relation, filter_config)
    return relation unless filters_applied && filter_config
    
    filter_config.each do |filter_name, filter_lambda|
      filter_value = filters_applied[filter_name.to_s]
      if filter_value.present?
        relation = filter_lambda.call(relation, filter_value)
      end
    end
    
    relation
  end
  
  # Legacy methods kept for backward compatibility
  def apply_filters(relation)
    config = REPORT_DATA_SOURCES[report_type]
    return relation unless config
    apply_configured_filters(relation, config[:filters])
  end
  
  def apply_anomaly_filters(relation)
    config = REPORT_DATA_SOURCES['anomalies']
    return relation unless config
    apply_configured_filters(relation, config[:filters])
  end
end
