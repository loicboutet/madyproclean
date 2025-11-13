class Admin::TimeEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'
  before_action :set_time_entry, only: [:show, :edit, :update, :destroy]
  
  def index
    @time_entries = TimeEntry.includes(:user, :site, :corrected_by).order(clocked_in_at: :desc)
    
    # Apply filters
    if params[:user_id].present?
      @time_entries = @time_entries.where(user_id: params[:user_id])
    end
    
    if params[:site_id].present?
      @time_entries = @time_entries.where(site_id: params[:site_id])
    end
    
    if params[:status].present?
      @time_entries = @time_entries.where(status: params[:status])
    end
    
    # Date range filter
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      @time_entries = @time_entries.where('clocked_in_at >= ?', start_date.beginning_of_day)
    end
    
    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      @time_entries = @time_entries.where('clocked_in_at <= ?', end_date.end_of_day)
    end
    
    # Calculate statistics before pagination
    @total_count = @time_entries.count
    @completed_count = @time_entries.where(status: 'completed').count
    @active_count = @time_entries.where(status: 'active').count
    @anomaly_count = @time_entries.where(status: 'anomaly').count
    
    # Paginate results (20 per page)
    @time_entries = @time_entries.page(params[:page]).per(20)
    
    # Load users and sites for filters
    @users = User.agents.active.order(:first_name, :last_name)
    @sites = Site.active.alphabetical
  end

  def show
    # @time_entry is set by before_action
  end

  def new
    @time_entry = TimeEntry.new
    @users = User.agents.active.order(:first_name, :last_name)
    @sites = Site.active.alphabetical
  end

  def create
    @time_entry = TimeEntry.new(time_entry_params)
    @time_entry.manually_corrected = true
    @time_entry.corrected_by = current_user
    @time_entry.corrected_at = Time.current
    
    if @time_entry.save
      redirect_to admin_time_entries_path, notice: 'Pointage créé avec succès.'
    else
      @users = User.agents.active.order(:first_name, :last_name)
      @sites = Site.active.alphabetical
      render :new, status: :unprocessable_entity
    end
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
      redirect_to edit_admin_time_entry_path(@time_entry), notice: 'Pointage mis à jour avec succès.'
    else
      @users = User.agents.active.order(:first_name, :last_name)
      @sites = Site.active.alphabetical
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @time_entry.destroy
    redirect_to admin_time_entries_path, notice: 'Pointage supprimé avec succès.'
  end

  def export
    # Apply same filters as index
    @time_entries = TimeEntry.includes(:user, :site).order(clocked_in_at: :desc)
    
    if params[:user_id].present?
      @time_entries = @time_entries.where(user_id: params[:user_id])
    end
    
    if params[:site_id].present?
      @time_entries = @time_entries.where(site_id: params[:site_id])
    end
    
    if params[:status].present?
      @time_entries = @time_entries.where(status: params[:status])
    end
    
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      @time_entries = @time_entries.where('clocked_in_at >= ?', start_date.beginning_of_day)
    end
    
    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      @time_entries = @time_entries.where('clocked_in_at <= ?', end_date.end_of_day)
    end
    
    respond_to do |format|
      format.csv do
        send_data generate_csv(@time_entries), filename: "pointages-#{Date.today}.csv"
      end
    end
  end

  private

  def set_time_entry
    @time_entry = TimeEntry.includes(:user, :site, :corrected_by).find_by(id: params[:id])
    
    unless @time_entry
      redirect_to admin_time_entries_path, alert: 'Pointage non trouvé.'
    end
  end

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
