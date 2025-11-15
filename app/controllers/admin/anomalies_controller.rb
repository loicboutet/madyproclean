class Admin::AnomaliesController < ApplicationController
  include AnomaliesManagement
  
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'

  private

  # Implementation of AnomaliesManagement abstract methods
  
  def anomalies_scope
    AnomalyLog
  end

  def anomalies_index_path
    admin_anomalies_path
  end

  def anomaly_path(anomaly)
    admin_anomaly_path(anomaly)
  end

  def users_for_filter
    User.agents.active.order(:first_name, :last_name)
  end

  def time_entries_for_filter
    TimeEntry.includes(:user, :site).order(created_at: :desc).limit(100)
  end

  def schedules_for_filter
    Schedule.includes(:user, :site).order(scheduled_date: :desc).limit(100)
  end
end
