class Dashboard::ProfilesController < ApplicationController
  layout 'manager'
  def show
    # Demo user data (no real model relation)
    @user = {
      id: 1,
      first_name: 'Jean',
      last_name: 'Dupont',
      email: 'jean.dupont@madyproclean.fr',
      employee_number: 'EMP-2023-001',
      phone_number: '+33 6 12 34 56 78',
      role: 'manager',
      active: true,
      created_at: 3.years.ago,
      manager_name: nil
    }

    # Demo statistics
    @stats = {
      total_time_entries: 245,
      total_hours_worked: 1960,
      current_month_hours: 152,
      absences_count: 8,
      managed_agents_count: 12,
      active_replacements: 3
    }

    # Demo recent activity
    @recent_activities = [
      {
        id: 1,
        type: 'time_entry',
        description: 'Pointage validé - Site Centrale Nucléaire A',
        date: 2.hours.ago,
        icon: 'clock'
      },
      {
        id: 2,
        type: 'absence',
        description: 'Absence déclarée pour Marie Martin (Congé maladie)',
        date: 1.day.ago,
        icon: 'calendar'
      },
      {
        id: 3,
        type: 'replacement',
        description: 'Remplacement assigné - Pierre Leblanc → Site B',
        date: 2.days.ago,
        icon: 'users'
      },
      {
        id: 4,
        type: 'schedule',
        description: 'Planning consulté pour la semaine prochaine',
        date: 3.days.ago,
        icon: 'calendar-check'
      }
    ]

    # Demo team members (for managers)
    @team_members = [
      { id: 1, name: 'Marie Martin', employee_number: 'EMP-2023-010', status: 'active', absences: 2 },
      { id: 2, name: 'Pierre Leblanc', employee_number: 'EMP-2023-011', status: 'active', absences: 0 },
      { id: 3, name: 'Sophie Bernard', employee_number: 'EMP-2023-012', status: 'active', absences: 1 },
      { id: 4, name: 'Luc Petit', employee_number: 'EMP-2023-013', status: 'active', absences: 0 },
      { id: 5, name: 'Claire Moreau', employee_number: 'EMP-2023-014', status: 'active', absences: 3 }
    ]
  end

  def edit
  end

  def update
  end
end
