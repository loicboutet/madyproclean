class Manager::SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'manager'
  before_action :set_schedule, only: [:show]
  before_action :load_demo_data
  
  def index
    # Apply filters to demo data (no logic, just show all)
    @schedules = @all_schedules.dup
    
    # Note: Filter logic intentionally not implemented as per requirements
    # Filters displayed in UI are for demonstration only
  end

  def show
    # @schedule is set by before_action
  end

  private

  def set_schedule
    load_demo_data
    @schedule = @all_schedules.find { |s| s[:id] == params[:id].to_i }
    
    unless @schedule
      redirect_to manager_schedules_path, alert: 'Planning non trouvé.'
    end
  end

  def load_demo_data
    # Demo users (agents)
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
    
    # Demo managers
    @demo_managers = [
      { id: 10, name: 'Responsable Principal', role: 'manager' },
      { id: 11, name: 'Superviseur Nord', role: 'manager' }
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
        scheduled_date: Date.parse('2025-02-10'),
        start_time: Time.parse('08:00'),
        end_time: Time.parse('16:00'),
        notes: 'Mission régulière de maintenance',
        status: 'scheduled',
        created_by_id: 10,
        created_by_name: 'Responsable Principal',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-01 10:00:00'),
        updated_at: Time.parse('2025-02-01 10:00:00')
      },
      {
        id: 2,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP002',
        site_id: 2,
        site_name: 'Centrale de Lyon',
        site_code: 'CLY-002',
        scheduled_date: Date.parse('2025-02-10'),
        start_time: Time.parse('09:00'),
        end_time: Time.parse('17:30'),
        notes: nil,
        status: 'scheduled',
        created_by_id: 11,
        created_by_name: 'Superviseur Nord',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-01 11:00:00'),
        updated_at: Time.parse('2025-02-01 11:00:00')
      },
      {
        id: 3,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP003',
        site_id: 1,
        site_name: 'Site Nucléaire Paris Nord',
        site_code: 'SPN-001',
        scheduled_date: Date.parse('2025-02-09'),
        start_time: Time.parse('07:00'),
        end_time: Time.parse('15:00'),
        notes: nil,
        status: 'completed',
        created_by_id: 10,
        created_by_name: 'Responsable Principal',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-01 10:30:00'),
        updated_at: Time.parse('2025-02-09 15:30:00')
      },
      {
        id: 4,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP001',
        site_id: 3,
        site_name: 'Station Marseille',
        site_code: 'SMA-003',
        scheduled_date: Date.parse('2025-02-08'),
        start_time: Time.parse('08:00'),
        end_time: Time.parse('16:30'),
        notes: 'Inspection de sécurité',
        status: 'completed',
        created_by_id: 10,
        created_by_name: 'Responsable Principal',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-01 09:00:00'),
        updated_at: Time.parse('2025-02-08 17:00:00')
      },
      {
        id: 5,
        user_id: 4,
        user_name: 'Sophie Bernard',
        employee_number: 'EMP004',
        site_id: 4,
        site_name: 'Centre Toulouse',
        site_code: 'CTO-004',
        scheduled_date: Date.parse('2025-02-07'),
        start_time: Time.parse('10:00'),
        end_time: Time.parse('18:00'),
        notes: nil,
        status: 'missed',
        created_by_id: 11,
        created_by_name: 'Superviseur Nord',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-01 14:00:00'),
        updated_at: Time.parse('2025-02-07 19:00:00')
      },
      {
        id: 6,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP002',
        site_id: 5,
        site_name: 'Unité Bordeaux',
        site_code: 'UBO-005',
        scheduled_date: Date.parse('2025-02-11'),
        start_time: Time.parse('09:00'),
        end_time: Time.parse('17:00'),
        notes: 'Formation spéciale requise',
        status: 'scheduled',
        created_by_id: 10,
        created_by_name: 'Responsable Principal',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-02 08:00:00'),
        updated_at: Time.parse('2025-02-02 08:00:00')
      },
      {
        id: 7,
        user_id: 5,
        user_name: 'Luc Petit',
        employee_number: 'EMP005',
        site_id: 2,
        site_name: 'Centrale de Lyon',
        site_code: 'CLY-002',
        scheduled_date: Date.parse('2025-02-11'),
        start_time: Time.parse('08:30'),
        end_time: Time.parse('16:30'),
        notes: nil,
        status: 'scheduled',
        created_by_id: 11,
        created_by_name: 'Superviseur Nord',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-02 10:00:00'),
        updated_at: Time.parse('2025-02-02 10:00:00')
      },
      {
        id: 8,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP003',
        site_id: 3,
        site_name: 'Station Marseille',
        site_code: 'SMA-003',
        scheduled_date: Date.parse('2025-02-12'),
        start_time: Time.parse('07:00'),
        end_time: Time.parse('15:30'),
        notes: nil,
        status: 'scheduled',
        created_by_id: 10,
        created_by_name: 'Responsable Principal',
        replaced_by_id: 5,
        replaced_by_name: 'Luc Petit',
        replacement_reason: 'Absence maladie de Pierre Durand',
        created_at: Time.parse('2025-02-03 09:00:00'),
        updated_at: Time.parse('2025-02-04 14:00:00')
      },
      {
        id: 9,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP001',
        site_id: 1,
        site_name: 'Site Nucléaire Paris Nord',
        site_code: 'SPN-001',
        scheduled_date: Date.parse('2025-02-06'),
        start_time: Time.parse('08:00'),
        end_time: Time.parse('16:00'),
        notes: nil,
        status: 'cancelled',
        created_by_id: 10,
        created_by_name: 'Responsable Principal',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-01 08:00:00'),
        updated_at: Time.parse('2025-02-05 16:00:00')
      },
      {
        id: 10,
        user_id: 4,
        user_name: 'Sophie Bernard',
        employee_number: 'EMP004',
        site_id: 5,
        site_name: 'Unité Bordeaux',
        site_code: 'UBO-005',
        scheduled_date: Date.parse('2025-02-13'),
        start_time: Time.parse('10:00'),
        end_time: Time.parse('18:00'),
        notes: 'Surveillance nocturne - horaires spéciaux',
        status: 'scheduled',
        created_by_id: 11,
        created_by_name: 'Superviseur Nord',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-03 11:00:00'),
        updated_at: Time.parse('2025-02-03 11:00:00')
      }
    ]
  end
end
