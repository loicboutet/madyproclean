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
    
    # Handle time entry correction if applicable
    correction_applied = false
    if @anomaly.anomaly_type_over_24h? && @anomaly.time_entry.present?
      correction_applied = apply_time_entry_correction(@anomaly)
    end
    
    # Handle resolution via checkbox
    was_resolved = @anomaly.resolved?
    is_being_resolved = params[:anomaly_log][:resolved] == '1'
    
    # If being marked as resolved for the first time, set resolved_by and resolved_at
    if is_being_resolved && !was_resolved
      params[:anomaly_log][:resolved_by_id] = current_user.id
      params[:anomaly_log][:resolved_at] = Time.current
    elsif !is_being_resolved && was_resolved
      # If unchecking resolved, clear the resolution fields
      params[:anomaly_log][:resolved_by_id] = nil
      params[:anomaly_log][:resolved_at] = nil
    end
    
    if @anomaly.update(anomaly_params)
      success_message = 'Anomalie mise à jour avec succès'
      success_message += ' et pointage corrigé' if correction_applied
      success_message += ' et marquée comme résolue' if is_being_resolved && !was_resolved
      redirect_to anomaly_path(@anomaly), notice: success_message
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
    
    # Auto-correct time entry for over_24h anomalies
    if @anomaly.anomaly_type_over_24h? && @anomaly.time_entry.present?
      time_entry = @anomaly.time_entry
      
      # Clock out and mark as corrected
      time_entry.correct(current_user, {
        clocked_out_at: Time.current,
        status: 'completed',
        notes: "Corrigé automatiquement lors de la résolution de l'anomalie >24h (ID: #{@anomaly.id})"
      })
    end
    
    # Resolve the anomaly
    if @anomaly.resolve!(current_user, params[:resolution_notes])
      redirect_to anomalies_index_path, notice: 'Anomalie résolue avec succès'
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

  # Apply time entry correction from form data
  def apply_time_entry_correction(anomaly)
    return false unless params[:anomaly_log][:time_entry_correction].present?
    
    correction_params = params[:anomaly_log][:time_entry_correction]
    
    # Check if user wants to apply correction
    return false unless correction_params[:apply_correction] == '1'
    
    time_entry = anomaly.time_entry
    correction_attributes = {}
    
    # Extract correction values from separate date and time fields
    if correction_params[:clocked_in_date].present? && correction_params[:clocked_in_time].present?
      clocked_in_str = "#{correction_params[:clocked_in_date]} #{correction_params[:clocked_in_time]}:00"
      correction_attributes[:clocked_in_at] = Time.zone.parse(clocked_in_str)
    end
    
    if correction_params[:clocked_out_date].present? && correction_params[:clocked_out_time].present?
      clocked_out_str = "#{correction_params[:clocked_out_date]} #{correction_params[:clocked_out_time]}:00"
      correction_attributes[:clocked_out_at] = Time.zone.parse(clocked_out_str)
    end
    
    # Validate clock_out is after clock_in
    if correction_attributes[:clocked_out_at].present?
      clocked_in = correction_attributes[:clocked_in_at] || time_entry.clocked_in_at
      if correction_attributes[:clocked_out_at] <= clocked_in
        anomaly.errors.add(:base, "L'heure de sortie doit être après l'heure d'entrée")
        return false
      end
    end
    
    # Add status and notes
    correction_attributes[:status] = 'completed' if correction_attributes[:clocked_out_at].present?
    
    if correction_params[:notes].present?
      existing_notes = time_entry.notes.present? ? "#{time_entry.notes}\n\n" : ""
      correction_attributes[:notes] = "#{existing_notes}[Correction #{Time.current.strftime('%d/%m/%Y %H:%M')}] #{correction_params[:notes]}"
    end
    
    # Apply correction
    time_entry.correct(current_user, correction_attributes)
    
    true
  rescue StandardError => e
    anomaly.errors.add(:base, "Erreur lors de la correction du pointage: #{e.message}")
    false
  end

  # Strong parameters for anomaly updates
  def anomaly_params
    params.require(:anomaly_log).permit(
      :anomaly_type,
      :severity,
      :description,
      :user_id,
      :time_entry_id,
      :schedule_id,
      :resolved,
      :resolution_notes,
      :resolved_by_id,
      :resolved_at
    )
  end
end
