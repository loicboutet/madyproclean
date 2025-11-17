namespace :manager_dashboard do
  desc "Generate sample data for manager dashboard testing"
  task generate: :environment do
    puts "🏗️  Generating sample data for manager dashboard..."
    
    # Create or find a manager
    manager = User.find_or_create_by!(email: 'manager@madyproclean.fr') do |u|
      u.first_name = 'Jean'
      u.last_name = 'Dupont'
      u.role = 'manager'
      u.password = 'password123'
      u.password_confirmation = 'password123'
      u.employee_number = 'MGR001'
      u.active = true
    end
    puts "✅ Manager created: #{manager.full_name} (#{manager.email})"
    
    # Create sites if they don't exist
    sites = []
    5.times do |i|
      site = Site.find_or_create_by!(code: "SITE-#{sprintf('%03d', i + 1)}") do |s|
        s.name = "Site #{['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon'][i]}"
        s.address = "#{10 + i * 5} Rue de la République, 7500#{i} Paris"
        s.description = "Site de production - Zone sécurisée niveau #{i + 1}"
        s.active = true
      end
      sites << site
    end
    puts "✅ Created #{sites.count} sites"
    
    # Create team members (agents) under the manager
    french_first_names = ['Marie', 'Pierre', 'Sophie', 'Luc', 'Julie', 'Antoine', 'Emma', 'Thomas', 'Camille', 'Nicolas']
    french_last_names = ['Martin', 'Bernard', 'Dubois', 'Thomas', 'Robert', 'Petit', 'Durand', 'Leroy', 'Moreau', 'Simon']
    
    team_members = []
    8.times do |i|
      agent = User.find_or_create_by!(email: "agent#{i + 1}@madyproclean.fr") do |u|
        u.first_name = french_first_names[i]
        u.last_name = french_last_names[i]
        u.role = 'agent'
        u.password = 'password123'
        u.password_confirmation = 'password123'
        u.employee_number = "AGT#{sprintf('%03d', i + 1)}"
        u.active = true
      end
      
      # Update manager association even if user already exists
      agent.update!(manager: manager) unless agent.manager_id == manager.id
      team_members << agent
    end
    puts "✅ Created #{team_members.count} team members under #{manager.full_name}"
    
    # Clean up any existing active time entries for team members
    TimeEntry.active.where(user_id: team_members.map(&:id)).destroy_all
    
    # Create time entries
    time_entries_count = 0
    
    # Active time entries for today (3-4 agents currently working)
    team_members.shuffle.take(rand(3..4)).each do |agent|
      site = sites.sample
      
      # Check if this agent already has an active entry today
      next if TimeEntry.active.where(user: agent).where('DATE(clocked_in_at) = ?', Date.current).exists?
      
      TimeEntry.create!(
        user: agent,
        site: site,
        clocked_in_at: Time.current - rand(1..6).hours,
        status: 'active',
        ip_address_in: "192.168.1.#{rand(10..250)}"
      )
      time_entries_count += 1
    end
    puts "✅ Created #{time_entries_count} active time entries for today"
    
    # Completed time entries for the last 7 days
    completed_count = 0
    (0..6).each do |days_ago|
      date = days_ago.days.ago.to_date
      
      # 4-6 entries per day
      rand(4..6).times do
        agent = team_members.sample
        site = sites.sample
        
        clock_in = date.to_time + rand(7..9).hours
        duration_hours = rand(6..10)
        clock_out = clock_in + duration_hours.hours
        duration_minutes = (duration_hours * 60).to_i
        
        TimeEntry.create!(
          user: agent,
          site: site,
          clocked_in_at: clock_in,
          clocked_out_at: clock_out,
          duration_minutes: duration_minutes,
          status: 'completed',
          ip_address_in: "192.168.1.#{rand(10..250)}",
          ip_address_out: "192.168.1.#{rand(10..250)}"
        )
        completed_count += 1
      end
    end
    puts "✅ Created #{completed_count} completed time entries for the last 7 days"
    
    # Create upcoming schedules
    schedules_count = 0
    (0..14).each do |days_ahead|
      date = days_ahead.days.from_now.to_date
      
      # 3-5 schedules per day
      rand(3..5).times do
        agent = team_members.sample
        site = sites.sample
        
        start_hour = rand(6..10)
        start_time = Time.parse("#{start_hour}:00")
        end_time = start_time + rand(6..10).hours
        
        begin
          Schedule.create!(
            user: agent,
            site: site,
            scheduled_date: date,
            start_time: start_time,
            end_time: end_time,
            status: 'scheduled',
            created_by: manager
          )
          schedules_count += 1
        rescue ActiveRecord::RecordInvalid
          # Skip if validation fails (e.g., overlapping schedules)
        end
      end
    end
    puts "✅ Created #{schedules_count} upcoming schedules"
    
    # Create absences for trend chart and upcoming absences table
    absences_count = 0
    absence_types = ['vacation', 'sick', 'training']
    
    # Historical absences for the last 6 weeks (for trend chart)
    (0..5).each do |weeks_ago|
      week_start = weeks_ago.weeks.ago.beginning_of_week
      
      # Generate 2-4 absences per week
      rand(2..4).times do
        agent = team_members.sample
        absence_type = absence_types.sample
        
        # Determine duration based on type
        duration = case absence_type
        when 'vacation'
          rand(5..10) # 5-10 days for vacation
        when 'sick'
          rand(1..3)  # 1-3 days for sick leave
        when 'training'
          rand(2..5)  # 2-5 days for training
        end
        
        start_date = week_start + rand(0..4).days
        end_date = start_date + (duration - 1).days
        
        Absence.create!(
          user: agent,
          absence_type: absence_type,
          start_date: start_date,
          end_date: end_date,
          status: 'approved',
          reason: case absence_type
                  when 'vacation'
                    ['Vacances familiales', 'Congés annuels', 'Vacances été'].sample
                  when 'sick'
                    ['Arrêt maladie', 'Grippe', 'Consultation médicale'].sample
                  when 'training'
                    ['Formation sécurité nucléaire', 'Formation incendie', 'Stage professionnel'].sample
                  end,
          created_by: manager
        )
        absences_count += 1
      end
    end
    
    # Upcoming absences (next 2-4 weeks for the table display)
    (0..3).each do |weeks_ahead|
      week_start = weeks_ahead.weeks.from_now.beginning_of_week
      
      # Generate 1-2 absences per week
      rand(1..2).times do
        agent = team_members.sample
        absence_type = absence_types.sample
        
        duration = case absence_type
        when 'vacation'
          rand(3..8)
        when 'sick'
          rand(1..2)
        when 'training'
          rand(2..3)
        end
        
        start_date = week_start + rand(0..4).days
        end_date = start_date + (duration - 1).days
        
        Absence.create!(
          user: agent,
          absence_type: absence_type,
          start_date: start_date,
          end_date: end_date,
          status: ['approved', 'pending'].sample,
          reason: case absence_type
                  when 'vacation'
                    ['Vacances familiales', 'Congés annuels', 'Week-end prolongé'].sample
                  when 'sick'
                    ['Arrêt maladie', 'Rendez-vous médical'].sample
                  when 'training'
                    ['Formation sécurité', 'Certification qualité'].sample
                  end,
          created_by: manager
        )
        absences_count += 1
      end
    end
    
    puts "✅ Created #{absences_count} absences (historical and upcoming)"
    
    puts "\n📊 Summary:"
    puts "   Manager: #{manager.full_name} (#{manager.email})"
    puts "   Team Members: #{manager.managed_users.active.count}"
    puts "   Sites: #{Site.active.count}"
    puts "   Active Time Entries Today: #{TimeEntry.active.where('DATE(clocked_in_at) = ?', Date.current).count}"
    puts "   Total Time Entries: #{TimeEntry.count}"
    puts "   Upcoming Schedules: #{Schedule.upcoming.count}"
    puts "   Total Absences: #{Absence.count}"
    puts "   Active Absences: #{Absence.active.count}"
    puts "   Upcoming Absences: #{Absence.upcoming.count}"
    puts "\n🔑 Login credentials:"
    puts "   Manager: manager@madyproclean.fr / password123"
    puts "   Agents: agent1@madyproclean.fr to agent8@madyproclean.fr / password123"
  end
  
  desc "Clean up all manager dashboard sample data"
  task cleanup: :environment do
    puts "🧹 Cleaning up manager dashboard sample data..."
    
    # Find the sample manager
    manager = User.find_by(email: 'manager@madyproclean.fr')
    
    if manager
      managed_user_ids = manager.managed_users.pluck(:id)
      
      # Delete absences first (both for managed users and created by manager)
      Absence.where(user_id: managed_user_ids).or(Absence.where(created_by_id: manager.id)).destroy_all
      puts "✅ Deleted absences for managed users and created by manager"
      
      # Delete schedules (both for managed users and created by manager)
      Schedule.where(user_id: managed_user_ids).or(Schedule.where(created_by_id: manager.id)).destroy_all
      puts "✅ Deleted schedules for managed users and created by manager"
      
      # Delete time entries for managed users
      TimeEntry.where(user_id: managed_user_ids).destroy_all
      puts "✅ Deleted time entries for managed users"
      
      # Delete anomaly logs for managed users
      AnomalyLog.where(user_id: managed_user_ids).or(AnomalyLog.where(resolved_by_id: manager.id)).destroy_all
      puts "✅ Deleted anomaly logs for managed users"
      
      # Delete managed users
      manager.managed_users.destroy_all
      puts "✅ Deleted managed users"
      
      # Delete manager
      manager.destroy
      puts "✅ Deleted manager"
    else
      puts "ℹ️  No sample manager found"
    end
    
    # Delete sample sites
    Site.where("code LIKE 'SITE-%'").destroy_all
    puts "✅ Deleted sample sites"
    
    puts "\n✅ Cleanup complete!"
  end
end
