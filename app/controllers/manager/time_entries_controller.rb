class Manager::TimeEntriesController < ApplicationController
  include TimeEntriesFilterable
  
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'manager'
  before_action :set_time_entry, only: [:show, :edit, :update]
  
  def index
    # Get base scope
    @time_entries = base_time_entries_scope
    
    # Apply filters
    @time_entries = apply_filters(@time_entries)
    
    # Calculate statistics before pagination
    calculate_statistics(@time_entries)
    
    # Paginate results (20 per page)
    @time_entries = @time_entries.page(params[:page]).per(20)
    
    # Load users and sites for filters
    load_filter_data
    
    # For backward compatibility with view that references @all_time_entries
    @all_time_entries = @time_entries
  end

  def show
    # @time_entry is set by before_action
  end

  def edit
    @users = User.agents.active.order(:first_name, :last_name)
    @sites = Site.active.alphabetical
  end

  def update
    # Set correction tracking before validation
    @time_entry.manually_corrected = true
    @time_entry.corrected_by = current_user
    @time_entry.corrected_at = Time.current
    
    # Apply the permitted params
    @time_entry.assign_attributes(time_entry_params)
    
    if @time_entry.save
      redirect_to manager_time_entry_path(@time_entry), notice: 'Pointage mis à jour avec succès.'
    else
      @users = User.agents.active.order(:first_name, :last_name)
      @sites = Site.active.alphabetical
      render :edit, status: :unprocessable_entity
    end
  end

  def export
    # Get base scope and apply same filters as index
    @time_entries = base_time_entries_scope
    @time_entries = apply_filters(@time_entries)
    
    respond_to do |format|
      format.csv do
        send_data generate_csv(@time_entries), filename: "pointages-#{Date.today}.csv"
      end
    end
  end

  private

  def time_entry_params
    params.require(:time_entry).permit(
      :user_id,
      :site_id,
      :clocked_in_at,
      :clocked_out_at,
      :status,
      :notes
    )
  end

  def set_time_entry
    @time_entry = TimeEntry.includes(:user, :site, :corrected_by).find_by(id: params[:id])
    
    unless @time_entry
      redirect_to manager_time_entries_path, alert: 'Pointage non trouvé.'
    end
  end

  def generate_csv(time_entries)
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      csv << ['ID', 'Agent', 'Numéro Employé', 'Site', 'Arrivée', 'Départ', 'Durée (minutes)', 'Statut', 'IP Arrivée', 'Corrigé Manuellement', 'Notes']
      
      time_entries.each do |entry|
        csv << [
          entry.id,
          entry.user.full_name,
          entry.user.employee_number,
          entry.site.name,
          entry.clocked_in_at&.strftime('%d/%m/%Y %H:%M'),
          entry.clocked_out_at&.strftime('%d/%m/%Y %H:%M'),
          entry.duration_minutes,
          entry.status,
          entry.ip_address_in,
          entry.manually_corrected ? 'Oui' : 'Non',
          entry.notes
        ]
      end
    end
  end
end
