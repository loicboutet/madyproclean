class Admin::SchedulesController < ApplicationController
  include SchedulesManagement
  
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]
  
  def index
    # Apply filters to demo data using the concern's filter method
    @schedules = filter_schedules(@all_schedules)
  end

  def show
    # @schedule is set by before_action from concern
  end

  def new
    @schedule = {
      id: nil,
      user_id: nil,
      site_id: nil,
      scheduled_date: Date.today,
      start_time: '09:00',
      end_time: '17:00',
      notes: '',
      status: 'scheduled',
      created_by_id: 1,
      replaced_by_id: nil,
      replacement_reason: ''
    }
  end

  def create
    # Simulate creating a new schedule
    new_schedule = {
      id: @all_schedules.length + 1,
      user_id: params[:schedule][:user_id].to_i,
      site_id: params[:schedule][:site_id].to_i,
      scheduled_date: Date.parse(params[:schedule][:scheduled_date]),
      start_time: params[:schedule][:start_time],
      end_time: params[:schedule][:end_time],
      notes: params[:schedule][:notes],
      status: params[:schedule][:status] || 'scheduled',
      created_by_id: 1,
      replaced_by_id: params[:schedule][:replaced_by_id].present? ? params[:schedule][:replaced_by_id].to_i : nil,
      replacement_reason: params[:schedule][:replacement_reason],
      created_at: Time.current,
      updated_at: Time.current
    }
    
    redirect_to admin_schedules_path, notice: 'Horaire créé avec succès.'
  end

  def edit
    # @schedule is set by before_action from concern
  end

  def update
    # Simulate updating
    @schedule[:user_id] = params[:schedule][:user_id].to_i if params[:schedule][:user_id]
    @schedule[:site_id] = params[:schedule][:site_id].to_i if params[:schedule][:site_id]
    @schedule[:scheduled_date] = Date.parse(params[:schedule][:scheduled_date]) if params[:schedule][:scheduled_date]
    @schedule[:start_time] = params[:schedule][:start_time] if params[:schedule][:start_time]
    @schedule[:end_time] = params[:schedule][:end_time] if params[:schedule][:end_time]
    @schedule[:notes] = params[:schedule][:notes] if params[:schedule][:notes]
    @schedule[:status] = params[:schedule][:status] if params[:schedule][:status]
    @schedule[:replaced_by_id] = params[:schedule][:replaced_by_id].present? ? params[:schedule][:replaced_by_id].to_i : nil
    @schedule[:replacement_reason] = params[:schedule][:replacement_reason] if params[:schedule][:replacement_reason]
    @schedule[:updated_at] = Time.current
    
    redirect_to admin_schedule_path(@schedule[:id]), notice: 'Horaire mis à jour avec succès.'
  end

  def destroy
    # Simulate deletion by marking as cancelled
    @schedule[:status] = 'cancelled'
    redirect_to admin_schedules_path, notice: 'Horaire annulé avec succès.'
  end

  def assign_replacement
    # Handle replacement assignment
  end

  def export
    # Handle export
  end

  private

  # Implement required abstract methods from SchedulesManagement concern
  def schedules_index_path
    admin_schedules_path
  end

  def schedule_path(id)
    admin_schedule_path(id)
  end

  def schedule_not_found_message
    'Horaire non trouvé.'
  end
end
