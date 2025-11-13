class Admin::SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]
  before_action :load_demo_data
  
  def index
    # Apply filters to demo data
    @schedules = @all_schedules.dup
    
    # Filter by status
    if params[:status].present?
      @schedules = @schedules.select { |s| s[:status] == params[:status] }
    end
    
    # Filter by site
    if params[:site_id].present?
      @schedules = @schedules.select { |s| s[:site_id] == params[:site_id].to_i }
    end
    
    # Filter by user
    if params[:user_id].present?
      @schedules = @schedules.select { |s| s[:user_id] == params[:user_id].to_i }
    end
    
    # Filter by date range
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      @schedules = @schedules.select { |s| s[:scheduled_date] >= start_date }
    end
    
    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      @schedules = @schedules.select { |s| s[:scheduled_date] <= end_date }
    end
    
    # Search by notes or user name
    if params[:search].present?
      search_term = params[:search].downcase
      @schedules = @schedules.select do |s|
        (s[:notes] && s[:notes].downcase.include?(search_term)) ||
        s[:user_name].downcase.include?(search_term) ||
        s[:site_name].downcase.include?(search_term)
      end
    end
  end

  def show
    # @schedule is set by before_action
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
    # @schedule is set by before_action
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

  def set_schedule
    load_demo_data
    @schedule = @all_schedules.find { |s| s[:id] == params[:id].to_i }
    
    unless @schedule
      redirect_to admin_schedules_path, alert: 'Horaire non trouvé.'
    end
  end

  def load_demo_data
    # Demo users
    @demo_users = [
      { id: 1, name: 'Jean Dupont', employee_number: 'EMP001', role: 'agent' },
      { id: 2, name: 'Marie Martin', employee_number: 'EMP002', role: 'agent' },
      { id: 3, name: 'Pierre Durand', employee_number: 'EMP003', role: 'agent' },
      { id: 4, name: 'Sophie Bernard', employee_number: 'EMP004', role: 'agent' },
      { id: 5, name: 'Luc Petit', employee_number: 'EMP005', role: 'agent' }
    ]
    
    # Demo sites
    @demo_sites = [
      { id: 1, name: 'Site Nucléaire Paris Nord', code: 'SPN-001' },
      { id: 2, name: 'Centrale de Lyon', code: 'CLY-002' },
      { id: 3, name: 'Station Marseille', code: 'SMA-003' },
      { id: 4, name: 'Centre Toulouse', code: 'CTO-004' },
      { id: 5, name: 'Unité Bordeaux', code: 'UBO-005' }
    ]
    
    # Demo schedules
    @all_schedules = [
      {
        id: 1,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP001',
        site_id: 1,
        site_name: 'Site Nucléaire Paris Nord',
        site_code: 'SPN-001',
        scheduled_date: Date.today,
        start_time: '08:00',
        end_time: '16:00',
        notes: 'Maintenance préventive zone A',
        status: 'scheduled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-01-15 10:00:00'),
        updated_at: Time.parse('2025-01-15 10:00:00')
      },
      {
        id: 2,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP002',
        site_id: 2,
        site_name: 'Centrale de Lyon',
        site_code: 'CLY-002',
        scheduled_date: Date.today,
        start_time: '09:00',
        end_time: '17:00',
        notes: 'Inspection routine des installations',
        status: 'scheduled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-01-20 14:30:00'),
        updated_at: Time.parse('2025-01-20 14:30:00')
      },
      {
        id: 3,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP003',
        site_id: 1,
        site_name: 'Site Nucléaire Paris Nord',
        site_code: 'SPN-001',
        scheduled_date: Date.today + 1,
        start_time: '07:00',
        end_time: '15:00',
        notes: 'Contrôle de sécurité hebdomadaire',
        status: 'scheduled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-01 11:00:00'),
        updated_at: Time.parse('2025-02-01 11:00:00')
      },
      {
        id: 4,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP001',
        site_id: 3,
        site_name: 'Station Marseille',
        site_code: 'SMA-003',
        scheduled_date: Date.today - 1,
        start_time: '08:00',
        end_time: '16:00',
        notes: 'Vérification équipements maritimes',
        status: 'completed',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-05 08:45:00'),
        updated_at: Time.parse('2025-02-06 16:30:00')
      },
      {
        id: 5,
        user_id: 4,
        user_name: 'Sophie Bernard',
        employee_number: 'EMP004',
        site_id: 4,
        site_name: 'Centre Toulouse',
        site_code: 'CTO-004',
        scheduled_date: Date.today - 2,
        start_time: '10:00',
        end_time: '18:00',
        notes: 'Formation nouveaux équipements',
        status: 'missed',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-10 13:00:00'),
        updated_at: Time.parse('2025-02-11 10:00:00')
      },
      {
        id: 6,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP002',
        site_id: 5,
        site_name: 'Unité Bordeaux',
        site_code: 'UBO-005',
        scheduled_date: Date.today + 2,
        start_time: '09:00',
        end_time: '17:00',
        notes: 'Intervention technique planifiée - Remplacée par Luc Petit suite à absence',
        status: 'scheduled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: 5,
        replaced_by_name: 'Luc Petit',
        replacement_reason: 'Absence maladie agent titulaire',
        created_at: Time.parse('2025-02-12 09:00:00'),
        updated_at: Time.parse('2025-02-14 11:30:00')
      },
      {
        id: 7,
        user_id: 5,
        user_name: 'Luc Petit',
        employee_number: 'EMP005',
        site_id: 2,
        site_name: 'Centrale de Lyon',
        site_code: 'CLY-002',
        scheduled_date: Date.today + 3,
        start_time: '08:30',
        end_time: '16:30',
        notes: 'Audit annuel des procédures',
        status: 'scheduled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-15 10:00:00'),
        updated_at: Time.parse('2025-02-15 10:00:00')
      },
      {
        id: 8,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP003',
        site_id: 3,
        site_name: 'Station Marseille',
        site_code: 'SMA-003',
        scheduled_date: Date.today - 5,
        start_time: '07:00',
        end_time: '15:00',
        notes: 'Intervention annulée - Conditions météo défavorables',
        status: 'cancelled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-01 08:00:00'),
        updated_at: Time.parse('2025-02-01 14:00:00')
      }
    ]
  end
end
