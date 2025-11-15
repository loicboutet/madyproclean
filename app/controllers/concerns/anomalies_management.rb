# frozen_string_literal: true

# AnomaliesManagement Concern
# Shared logic for Admin::AnomaliesController and Manager::AnomaliesController
# 
# Following the same pattern as ReportsGeneration concern
# Each controller must implement:
# - anomalies_scope: Returns the base query scope
# - anomalies_index_path: Returns the index path for redirects
# - anomaly_path(anomaly): Returns the show path for a specific anomaly
# - users_for_filter: Returns the users list for filter dropdown

module AnomaliesManagement
  extend ActiveSupport::Concern

  included do
    before_action :set_anomaly, only: [:show, :edit, :update]
  end

  # GET /anomalies
  def index
    # Build base query with filters
    @anomalies = build_base_query
    @anomalies = apply_filters(@anomalies)
    
    # Get all anomalies for statistics (before pagination)
    @all_anomalies = @anomalies
    
    # Paginate
    @anomalies = @anomalies.page(params[:page]).per(20)
    
    # Get user list for filter dropdown
    @users = users_for_filter
  end

  # GET /anomalies/:id
  def show
    # @anomaly is set by before_action
  end

  # GET /anomalies/:id/edit
  def edit
    # @anomaly is set by before_action
    @users = users_for_filter
    @time_entries = time_entries_for_filter
    @schedules = schedules_for_filter
  end

  # PATCH/PUT /anomalies/:id
  def update
    @anomaly = anomalies_scope.find(params[:id])
    
    if @anomaly.update(anomaly_params)
      redirect_to anomaly_path(@anomaly), notice: 'Anomalie mise à jour avec succès'
    else
      @users = users_for_filter
      @time_entries = time_entries_for_filter
      @schedules = schedules_for_filter
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to anomalies_index_path, alert: 'Anomalie non trouvée'
  end

  # POST /anomalies/:id/resolve
  def resolve
    @anomaly = anomalies_scope.find(params[:id])
    
    if @anomaly.resolve!(current_user, params[:resolution_notes])
      redirect_to anomalies_index_path, notice: 'Anomalie marquée comme résolue'
    else
      redirect_to anomaly_path(@anomaly), alert: 'Erreur lors de la résolution de l\'anomalie'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to anomalies_index_path, alert: 'Anomalie non trouvée'
  end

  private

  # Build base query with associations
  def build_base_query
    anomalies_scope
      .includes(:user, :time_entry, :schedule, :resolved_by)
      .recent
  end

  # Apply all filters to the anomalies query
  def apply_filters(query)
    query = query.where('description LIKE ?', "%#{params[:search]}%") if params[:search].present?
    query = query.by_type(params[:anomaly_type]) if params[:anomaly_type].present?
    query = query.by_severity(params[:severity]) if params[:severity].present?
    query = query.where(user_id: params[:user_id]) if params[:user_id].present?
    query = query.for_date(params[:date]) if params[:date].present?
    
    # Filter by resolved status
    if params[:resolved].present?
      query = params[:resolved] == 'true' ? query.resolved : query.unresolved
    end
    
    query
  end

  # Set anomaly for show action
  def set_anomaly
    @anomaly = anomalies_scope
                 .includes(:user, :time_entry, :schedule, :resolved_by)
                 .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to anomalies_index_path, alert: 'Anomalie non trouvée'
  end

  # Abstract methods - must be implemented by including controller
  def anomalies_scope
    raise NotImplementedError, "#{self.class} must implement #anomalies_scope"
  end

  def anomalies_index_path
    raise NotImplementedError, "#{self.class} must implement #anomalies_index_path"
  end

  def anomaly_path(anomaly)
    raise NotImplementedError, "#{self.class} must implement #anomaly_path"
  end

  def users_for_filter
    raise NotImplementedError, "#{self.class} must implement #users_for_filter"
  end

  def time_entries_for_filter
    raise NotImplementedError, "#{self.class} must implement #time_entries_for_filter"
  end

  def schedules_for_filter
    raise NotImplementedError, "#{self.class} must implement #schedules_for_filter"
  end

  # Strong parameters for anomaly updates
  def anomaly_params
    params.require(:anomaly_log).permit(
      :anomaly_type,
      :severity,
      :description,
      :user_id,
      :time_entry_id,
      :schedule_id
    )
  end
end
