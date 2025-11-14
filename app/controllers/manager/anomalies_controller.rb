class Manager::AnomaliesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'manager'
  
  def index
    # Build query with filters - only for manager's team
    @anomalies = AnomalyLog.includes(:user, :time_entry, :schedule, :resolved_by)
                           .where(user: managed_users)
                           .recent
    
    # Apply filters
    @anomalies = @anomalies.where('description LIKE ?', "%#{params[:search]}%") if params[:search].present?
    @anomalies = @anomalies.by_type(params[:anomaly_type]) if params[:anomaly_type].present?
    @anomalies = @anomalies.by_severity(params[:severity]) if params[:severity].present?
    @anomalies = @anomalies.where(user_id: params[:user_id]) if params[:user_id].present?
    @anomalies = @anomalies.for_date(params[:date]) if params[:date].present?
    
    # Filter by resolved status
    if params[:resolved].present?
      @anomalies = params[:resolved] == 'true' ? @anomalies.resolved : @anomalies.unresolved
    end
    
    # Get all anomalies for statistics (before pagination)
    @all_anomalies = @anomalies
    
    # Paginate
    @anomalies = @anomalies.page(params[:page]).per(20)
    
    # Get user list for filter dropdown (only managed users)
    @users = managed_users.order(:first_name, :last_name)
  end

  def show
    @anomaly = AnomalyLog.includes(:user, :time_entry, :schedule, :resolved_by)
                         .where(user: managed_users)
                         .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to manager_anomalies_path, alert: 'Anomalie non trouvée ou accès non autorisé'
  end

  def resolve
    @anomaly = AnomalyLog.where(user: managed_users).find(params[:id])
    
    if @anomaly.resolve!(current_user, params[:resolution_notes])
      redirect_to manager_anomalies_path, notice: 'Anomalie marquée comme résolue'
    else
      redirect_to manager_anomaly_path(@anomaly), alert: 'Erreur lors de la résolution de l\'anomalie'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to manager_anomalies_path, alert: 'Anomalie non trouvée ou accès non autorisé'
  end

  private

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
