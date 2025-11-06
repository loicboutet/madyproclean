class Manager::TeamController < ApplicationController
  layout 'manager'
  
  def index
    # Demo data for sites
    @demo_sites = [
      { id: 1, name: 'Site Central Lyon', code: 'LYN-001' },
      { id: 2, name: 'Site Nord Paris', code: 'PAR-002' },
      { id: 3, name: 'Site Est Strasbourg', code: 'STR-003' },
      { id: 4, name: 'Site Sud Marseille', code: 'MAR-004' }
    ]

    # Demo data for users (agents)
    @demo_users = [
      { id: 1, name: 'Jean Dupont', employee_number: 'EMP-001' },
      { id: 2, name: 'Marie Martin', employee_number: 'EMP-002' },
      { id: 3, name: 'Pierre Durand', employee_number: 'EMP-003' },
      { id: 4, name: 'Sophie Bernard', employee_number: 'EMP-004' },
      { id: 5, name: 'Luc Moreau', employee_number: 'EMP-005' }
    ]

    # Demo data for all schedules
    @all_schedules = [
      {
        id: 1,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP-001',
        site_id: 1,
        site_name: 'Site Central Lyon',
        site_code: 'LYN-001',
        scheduled_date: Date.today,
        start_time: Time.parse('08:00'),
        end_time: Time.parse('16:00'),
        status: 'scheduled',
        notes: 'Intervention standard',
        created_by_name: 'Admin Principal',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: 2.days.ago,
        updated_at: 2.days.ago
      },
      {
        id: 2,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP-002',
        site_id: 2,
        site_name: 'Site Nord Paris',
        site_code: 'PAR-002',
        scheduled_date: Date.today,
        start_time: Time.parse('09:00'),
        end_time: Time.parse('17:00'),
        status: 'completed',
        notes: 'Maintenance préventive',
        created_by_name: 'Admin Principal',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: 3.days.ago,
        updated_at: 1.day.ago
      },
      {
        id: 3,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP-003',
        site_id: 3,
        site_name: 'Site Est Strasbourg',
        site_code: 'STR-003',
        scheduled_date: Date.today + 1.day,
        start_time: Time.parse('07:30'),
        end_time: Time.parse('15:30'),
        status: 'scheduled',
        notes: 'Inspection mensuelle',
        created_by_name: 'Manager Superviseur',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: 1.week.ago,
        updated_at: 1.week.ago
      },
      {
        id: 4,
        user_id: 4,
        user_name: 'Sophie Bernard',
        employee_number: 'EMP-004',
        site_id: 4,
        site_name: 'Site Sud Marseille',
        site_code: 'MAR-004',
        scheduled_date: Date.today - 1.day,
        start_time: Time.parse('08:00'),
        end_time: Time.parse('16:00'),
        status: 'missed',
        notes: 'Absence non signalée',
        created_by_name: 'Admin Principal',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: 1.week.ago,
        updated_at: 1.day.ago
      },
      {
        id: 5,
        user_id: 5,
        user_name: 'Luc Moreau',
        employee_number: 'EMP-005',
        site_id: 1,
        site_name: 'Site Central Lyon',
        site_code: 'LYN-001',
        scheduled_date: Date.today + 2.days,
        start_time: Time.parse('10:00'),
        end_time: Time.parse('18:00'),
        status: 'scheduled',
        notes: 'Formation sur site',
        created_by_name: 'Manager Superviseur',
        replaced_by_id: 3,
        replaced_by_name: 'Pierre Durand',
        replacement_reason: 'Remplacement pour congés maladie',
        created_at: 5.days.ago,
        updated_at: 2.days.ago
      },
      {
        id: 6,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP-001',
        site_id: 2,
        site_name: 'Site Nord Paris',
        site_code: 'PAR-002',
        scheduled_date: Date.today - 2.days,
        start_time: Time.parse('08:00'),
        end_time: Time.parse('16:00'),
        status: 'cancelled',
        notes: 'Annulé - Problème technique sur site',
        created_by_name: 'Admin Principal',
        replaced_by_id: nil,
        replacement_reason: nil,
        created_at: 1.week.ago,
        updated_at: 2.days.ago
      }
    ]

    # Paginated schedules for display (no real filtering logic)
    @schedules = @all_schedules
  end

  def show
    # Demo data for a specific schedule
    schedule_id = params[:id].to_i
    
    @demo_schedule = {
      id: schedule_id,
      user_id: 1,
      user_name: 'Jean Dupont',
      employee_number: 'EMP-001',
      site_id: 1,
      site_name: 'Site Central Lyon',
      site_code: 'LYN-001',
      site_address: '15 Rue de la République, 69001 Lyon',
      scheduled_date: Date.today,
      start_time: Time.parse('08:00'),
      end_time: Time.parse('16:00'),
      status: 'scheduled',
      notes: 'Intervention standard - Maintenance préventive des équipements',
      created_by_id: 1,
      created_by_name: 'Admin Principal',
      replaced_by_id: nil,
      replaced_by_name: nil,
      replacement_reason: nil,
      created_at: 2.days.ago,
      updated_at: 2.days.ago
    }
  end
end
