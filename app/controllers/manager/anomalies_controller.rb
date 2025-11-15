class Manager::AnomaliesController < ApplicationController
  include AnomaliesManagement
  
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'manager'

  private

  # Implementation of AnomaliesManagement abstract methods
  
  def anomalies_scope
    AnomalyLog.where(user: managed_users)
  end

  def anomalies_index_path
    manager_anomalies_path
  end

  def anomaly_path(anomaly)
    manager_anomaly_path(anomaly)
  end

  def users_for_filter
    managed_users.order(:first_name, :last_name)
  end

  # Manager-specific helper methods
  
  def authorize_manager!
    unless current_user.manager? || current_user.admin?
      redirect_to root_path, alert: 'Accès non autorisé'
    end
  end

  def managed_users
    # For now, managers can see all agents
    # This can be refined later to scope to specific teams
    @managed_users ||= User.agents.active
  end
end
