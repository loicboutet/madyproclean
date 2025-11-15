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
end
