class Manager::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'manager'
  
  def index
    # Get all agents (managers see all agents, not just their managed users)
    @team_members = User.agents.active
    @team_member_ids = @team_members.pluck(:id)
    
    # Statistics
    @team_count = @team_members.count
    @active_today_count = TimeEntry.where(user_id: @team_member_ids)
                                    .where('DATE(clocked_in_at) = ?', Date.current)
                                    .active.count
    # Active absences count
    @absences_count = Absence.where(user_id: @team_member_ids).active.count
    
    # Sites covered by team
    @sites_coverage = Site.active
                          .joins(:time_entries)
                          .where(time_entries: { user_id: @team_member_ids, status: 'active' })
                          .distinct
                          .select('sites.*, COUNT(time_entries.id) as agents_count')
                          .group('sites.id')
                          .order(:name)
    @sites_count = @sites_coverage.length
    
    # Recent time entries (last 5)
    @recent_time_entries = TimeEntry.includes(:user, :site)
                                    .where(user_id: @team_member_ids)
                                    .order(clocked_in_at: :desc)
                                    .limit(5)
    
    # Upcoming schedules (next 8 for display)
    @upcoming_schedules = Schedule.includes(:user, :site)
                                  .where(user_id: @team_member_ids)
                                  .where('scheduled_date >= ?', Date.current)
                                  .order(scheduled_date: :asc, start_time: :asc)
                                  .limit(8)
    
    # Upcoming absences for display in table
    @upcoming_absences = Absence.includes(:user)
                                .where(user_id: @team_member_ids)
                                .upcoming
                                .limit(10)
    
    # Chart data
    @chart_data = {
      team_activity: team_activity_chart_data,
      absences_trend: absences_trend_chart_data
    }
  end

  private

  def team_activity_chart_data
    # Get last 7 days of data
    start_date = 6.days.ago.to_date
    end_date = Date.current
    
    # Build labels and data arrays for last 7 days
    labels = []
    agents_data = []
    hours_data = []
    
    (start_date..end_date).each do |date|
      labels << date.strftime('%a')
      
      # Query time entries for this specific date
      entries_for_date = TimeEntry.where(user_id: @team_member_ids)
                                   .where('DATE(clocked_in_at) = ?', date)
      
      # Count distinct users (agents) for this date
      agents_count = entries_for_date.distinct.count(:user_id)
      
      # Sum total duration in minutes for this date
      total_minutes = entries_for_date.sum(:duration_minutes) || 0
      
      # Add to data arrays
      agents_data << agents_count
      hours_data << (total_minutes / 60.0).round(1)
    end
    
    {
      labels: labels,
      datasets: [
        {
          label: 'Agents Actifs',
          data: agents_data,
          backgroundColor: 'rgba(0, 212, 255, 0.6)',
          borderColor: 'rgba(0, 212, 255, 1)',
          borderWidth: 2
        },
        {
          label: 'Heures Travaillées',
          data: hours_data,
          backgroundColor: 'rgba(0, 255, 224, 0.6)',
          borderColor: 'rgba(0, 255, 224, 1)',
          borderWidth: 2
        }
      ]
    }
  end

  def absences_trend_chart_data
    # Get data for the last 6 weeks
    weeks_count = 6
    start_date = (weeks_count - 1).weeks.ago.beginning_of_week
    end_date = Date.current
    
    # Get all absences for team members in the date range
    absences = Absence.where(user_id: @team_member_ids)
                      .where('start_date <= ? AND end_date >= ?', end_date, start_date)
                      .select(:absence_type, :start_date, :end_date)
    
    # Initialize data structures
    labels = []
    vacation_data = []
    sick_data = []
    training_data = []
    
    # Build week labels and count absences per week
    (0...weeks_count).each do |week_offset|
      week_start = (weeks_count - 1 - week_offset).weeks.ago.beginning_of_week
      week_end = week_start.end_of_week
      
      # Create label for the week
      if week_offset == weeks_count - 1
        # Last complete month name
        labels << I18n.l(week_start, format: '%b')
      else
        # Week number for current month
        week_number = weeks_count - week_offset
        labels << "Sem #{week_number} #{I18n.l(week_start, format: '%b')}"
      end
      
      # Count absences by type for this week
      vacation_count = 0
      sick_count = 0
      training_count = 0
      
      absences.each do |absence|
        # Check if absence overlaps with this week
        if absence.end_date >= week_start && absence.start_date <= week_end
          case absence.absence_type
          when 'vacation'
            vacation_count += 1
          when 'sick'
            sick_count += 1
          when 'training'
            training_count += 1
          end
        end
      end
      
      vacation_data << vacation_count
      sick_data << sick_count
      training_data << training_count
    end
    
    {
      labels: labels,
      datasets: [
        {
          label: 'Congés',
          data: vacation_data,
          borderColor: 'rgba(0, 255, 224, 1)',
          backgroundColor: 'rgba(0, 255, 224, 0.1)',
          tension: 0.4,
          fill: true
        },
        {
          label: 'Maladie',
          data: sick_data,
          borderColor: 'rgba(255, 193, 7, 1)',
          backgroundColor: 'rgba(255, 193, 7, 0.1)',
          tension: 0.4,
          fill: true
        },
        {
          label: 'Formation',
          data: training_data,
          borderColor: 'rgba(0, 212, 255, 1)',
          backgroundColor: 'rgba(0, 212, 255, 0.1)',
          tension: 0.4,
          fill: true
        }
      ]
    }
  end
end
