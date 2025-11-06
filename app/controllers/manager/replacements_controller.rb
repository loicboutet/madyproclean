class Manager::ReplacementsController < ApplicationController
  layout 'manager'
  
  def index
    # Demo data for available agents for replacement
    @demo_agents = [
      { id: 1, name: 'Jean Dupont', employee_number: 'EMP-001', available: true },
      { id: 2, name: 'Marie Martin', employee_number: 'EMP-002', available: true },
      { id: 3, name: 'Pierre Durand', employee_number: 'EMP-003', available: true },
      { id: 4, name: 'Sophie Bernard', employee_number: 'EMP-004', available: false },
      { id: 5, name: 'Luc Moreau', employee_number: 'EMP-005', available: true },
      { id: 6, name: 'Claire Lefebvre', employee_number: 'EMP-006', available: true },
      { id: 7, name: 'Thomas Petit', employee_number: 'EMP-007', available: true }
    ]

    # Demo data for sites
    @demo_sites = [
      { id: 1, name: 'Site Central Lyon', code: 'LYN-001' },
      { id: 2, name: 'Site Nord Paris', code: 'PAR-002' },
      { id: 3, name: 'Site Est Strasbourg', code: 'STR-003' },
      { id: 4, name: 'Site Sud Marseille', code: 'MAR-004' }
    ]

    # Demo data for schedules needing replacements
    @all_schedules = [
      {
        id: 1,
        user_id: 4,
        user_name: 'Sophie Bernard',
        employee_number: 'EMP-004',
        site_id: 1,
        site_name: 'Site Central Lyon',
        site_code: 'LYN-001',
        scheduled_date: Date.today + 1.day,
        start_time: Time.parse('08:00'),
        end_time: Time.parse('16:00'),
        status: 'scheduled',
        notes: 'Agent absent - maladie',
        replacement_needed: true,
        replacement_reason_current: 'Congé maladie - certificat médical',
        replaced_by_id: nil,
        replaced_by_name: nil,
        created_at: 3.days.ago
      },
      {
        id: 2,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP-001',
        site_id: 2,
        site_name: 'Site Nord Paris',
        site_code: 'PAR-002',
        scheduled_date: Date.today + 2.days,
        start_time: Time.parse('09:00'),
        end_time: Time.parse('17:00'),
        status: 'scheduled',
        notes: 'Agent en formation',
        replacement_needed: true,
        replacement_reason_current: 'Formation obligatoire - 2 jours',
        replaced_by_id: nil,
        replaced_by_name: nil,
        created_at: 5.days.ago
      },
      {
        id: 3,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP-002',
        site_id: 3,
        site_name: 'Site Est Strasbourg',
        site_code: 'STR-003',
        scheduled_date: Date.today + 3.days,
        start_time: Time.parse('07:30'),
        end_time: Time.parse('15:30'),
        status: 'scheduled',
        notes: 'Congé planifié',
        replacement_needed: true,
        replacement_reason_current: 'Congé annuel validé',
        replaced_by_id: nil,
        replaced_by_name: nil,
        created_at: 1.week.ago
      },
      {
        id: 4,
        user_id: 5,
        user_name: 'Luc Moreau',
        employee_number: 'EMP-005',
        site_id: 4,
        site_name: 'Site Sud Marseille',
        site_code: 'MAR-004',
        scheduled_date: Date.today,
        start_time: Time.parse('08:00'),
        end_time: Time.parse('16:00'),
        status: 'scheduled',
        notes: 'Urgence familiale',
        replacement_needed: true,
        replacement_reason_current: 'Urgence familiale - absence imprévue',
        replaced_by_id: nil,
        replaced_by_name: nil,
        created_at: 1.day.ago
      },
      {
        id: 5,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP-003',
        site_id: 1,
        site_name: 'Site Central Lyon',
        site_code: 'LYN-001',
        scheduled_date: Date.today + 4.days,
        start_time: Time.parse('10:00'),
        end_time: Time.parse('18:00'),
        status: 'scheduled',
        notes: 'Remplacement déjà effectué',
        replacement_needed: false,
        replacement_reason_current: 'Congé parental',
        replaced_by_id: 6,
        replaced_by_name: 'Claire Lefebvre',
        replacement_assigned_at: 2.days.ago,
        created_at: 1.week.ago
      }
    ]

    # Only show schedules needing replacement (unless showing all)
    @schedules = @all_schedules.select { |s| s[:replacement_needed] }
  end

  def assign
    # This would handle the replacement assignment
    # For demo purposes, just redirect back with a success message
    redirect_to manager_replacements_path, notice: 'Remplacement assigné avec succès (DEMO)'
  end
end
