namespace :reports do
  desc "Generate sample time entries for testing monthly reports (without deleting existing data)"
  task generate_sample_data: :environment do
    puts "\n🕐 Generating sample time entries for monthly reports testing..."
    puts "=" * 60
    
    # Check if we have users and sites
    if User.count.zero? || Site.count.zero?
      puts "❌ ERROR: No users or sites found!"
      puts "   Please run 'rails db:seed' first to create users and sites."
      exit 1
    end
    
    # Get existing agents and sites
    agents = User.agents.active
    sites = Site.active
    
    if agents.count < 3
      puts "⚠️  Warning: Only #{agents.count} agent(s) found. Creating more for realistic data..."
      # Create a few more agents if needed
      manager = User.managers.first || User.admins.first
      
      5.times do |i|
        next if User.exists?(employee_number: "TEMP#{i+1}")
        
        agent = User.create!(
          email: "temp.agent#{i+1}@madyproclean.fr",
          password: 'password123',
          password_confirmation: 'password123',
          first_name: ['Alex', 'Sam', 'Jordan', 'Morgan', 'Casey'][i],
          last_name: ['Temp', 'Test', 'Sample', 'Demo', 'Trial'][i],
          role: 'agent',
          employee_number: "TEMP#{i+1}",
          manager: manager,
          active: true
        )
        agents = agents.or(User.where(id: agent.id))
        puts "  ✓ Created temporary agent: #{agent.full_name}"
      end
    end
    
    if sites.count < 2
      puts "⚠️  Warning: Only #{sites.count} site(s) found. Need at least 2 sites."
      exit 1
    end
    
    puts "\n📊 Using existing data:"
    puts "   - Agents: #{agents.count}"
    puts "   - Sites: #{sites.count}"
    
    # Generate entries for the last 3 months
    entries_created = 0
    anomalies_created = 0
    
    puts "\n📅 Generating time entries for last 3 months..."
    
    3.times do |month_offset|
      start_date = Date.current.beginning_of_month - month_offset.months
      end_date = start_date.end_of_month
      
      month_name = start_date.strftime('%B %Y')
      puts "\n  Processing #{month_name}..."
      
      working_days = 0
      entries_this_month = 0
      
      # Generate entries for each working day
      (start_date..end_date).each do |date|
        next if date.saturday? || date.sunday?
        working_days += 1
        
        # Random 3-5 agents work each day
        working_agents = agents.to_a.sample(rand(3..5))
        
        working_agents.each do |agent|
          site = sites.to_a.sample
          
          # Random start time between 7:00 and 9:00
          start_hour = rand(7..9)
          start_minute = [0, 15, 30, 45].sample
          clocked_in = Time.zone.local(date.year, date.month, date.day, start_hour, start_minute)
          
          # Work duration between 6 and 10 hours
          duration_hours = rand(6..10)
          duration_minutes = duration_hours * 60 + [0, 15, 30, 45].sample
          clocked_out = clocked_in + duration_minutes.minutes
          
          # Skip if entry already exists for this agent/site/date
          next if TimeEntry.exists?(
            user: agent,
            site: site,
            clocked_in_at: date.beginning_of_day..date.end_of_day
          )
          
          # Create time entry
          entry = TimeEntry.create!(
            user: agent,
            site: site,
            clocked_in_at: clocked_in,
            clocked_out_at: clocked_out,
            duration_minutes: duration_minutes,
            status: 'completed',
            ip_address_in: "192.168.1.#{rand(100..200)}",
            ip_address_out: "192.168.1.#{rand(100..200)}"
          )
          entries_created += 1
          entries_this_month += 1
          
          # Occasionally create an anomaly (5% chance)
          if rand < 0.05
            anomaly_types = ['missed_clock_in', 'missed_clock_out', 'schedule_mismatch']
            AnomalyLog.create!(
              anomaly_type: anomaly_types.sample,
              severity: ['low', 'medium', 'high'].sample,
              user: agent,
              time_entry: entry,
              description: "Anomalie détectée: #{anomaly_types.sample.humanize}",
              resolved: [true, false].sample
            )
            anomalies_created += 1
          end
        end
      end
      
      puts "    ✓ Created #{entries_this_month} entries for #{month_name} (#{working_days} working days)"
    end
    
    # Create a few active entries for today
    puts "\n⏱️  Creating active entries for today..."
    active_count = 0
    agents.to_a.sample([3, agents.count].min).each do |agent|
      site = sites.to_a.sample
      
      # Skip if agent already has an active entry today
      next if TimeEntry.exists?(
        user: agent,
        clocked_in_at: Date.current.beginning_of_day..Date.current.end_of_day,
        clocked_out_at: nil
      )
      
      clocked_in = Time.current - rand(1..4).hours
      
      TimeEntry.create!(
        user: agent,
        site: site,
        clocked_in_at: clocked_in,
        clocked_out_at: nil,
        duration_minutes: nil,
        status: 'active',
        ip_address_in: "192.168.1.#{rand(100..200)}"
      )
      entries_created += 1
      active_count += 1
    end
    puts "    ✓ Created #{active_count} active entries"
    
    # Create a few anomaly entries (old entries never closed)
    puts "\n⚠️  Creating anomaly entries (old unclosed entries)..."
    anomaly_entries = 0
    agents.to_a.sample([3, agents.count].min).each do |agent|
      site = sites.to_a.sample
      days_ago = rand(2..5)
      
      # Skip if this would duplicate
      next if TimeEntry.exists?(
        user: agent,
        clocked_in_at: days_ago.days.ago.beginning_of_day..days_ago.days.ago.end_of_day,
        clocked_out_at: nil
      )
      
      clocked_in = days_ago.days.ago.beginning_of_day + rand(7..9).hours
      
      entry = TimeEntry.create!(
        user: agent,
        site: site,
        clocked_in_at: clocked_in,
        clocked_out_at: nil,
        duration_minutes: nil,
        status: 'anomaly',
        ip_address_in: "192.168.1.#{rand(100..200)}",
        notes: 'Anomalie: pas de pointage de départ depuis plus de 24h'
      )
      
      AnomalyLog.create!(
        anomaly_type: 'missed_clock_out',
        severity: 'high',
        user: agent,
        time_entry: entry,
        description: "Pointage non fermé depuis #{days_ago} jours",
        resolved: false
      )
      
      entries_created += 1
      anomaly_entries += 1
      anomalies_created += 1
    end
    puts "    ✓ Created #{anomaly_entries} anomaly entries"
    
    puts "\n" + "=" * 60
    puts "✅ Sample data generation complete!"
    puts "\n📊 Summary:"
    puts "   - New time entries created: #{entries_created}"
    puts "   - New anomalies created: #{anomalies_created}"
    puts "   - Total time entries now: #{TimeEntry.count}"
    puts "   - Total anomaly logs now: #{AnomalyLog.count}"
    
    puts "\n💡 Next steps:"
    puts "   1. Login at http://localhost:3000/login"
    puts "      Email: admin@madyproclean.fr"
    puts "      Password: password123"
    puts "   2. Navigate to /admin/reports"
    puts "   3. Click 'Rapport Mensuel' card"
    puts "   4. Select current month and generate report"
    puts "\n   You can run this task multiple times to add more data."
    puts "   Existing entries won't be duplicated (checked by agent/site/date)."
    puts "\n"
  end
  
  desc "Clear sample time entries (keeps users and sites)"
  task clear_sample_data: :environment do
    puts "\n🗑️  Clearing sample time entries..."
    
    count = TimeEntry.count
    TimeEntry.destroy_all
    puts "   ✓ Deleted #{count} time entries"
    
    count = AnomalyLog.count
    AnomalyLog.destroy_all
    puts "   ✓ Deleted #{count} anomaly logs"
    
    puts "\n✅ Sample data cleared!"
    puts "   Users and Sites remain intact."
    puts "\n"
  end
  
  desc "Show current data statistics"
  task stats: :environment do
    puts "\n📊 Current Database Statistics"
    puts "=" * 60
    puts "Users:"
    puts "   - Admins: #{User.admins.count}"
    puts "   - Managers: #{User.managers.count}"
    puts "   - Agents (active): #{User.agents.active.count}"
    puts "   - Total: #{User.count}"
    puts "\nSites:"
    puts "   - Active: #{Site.active.count}"
    puts "   - Total: #{Site.count}"
    puts "\nTime Entries:"
    puts "   - Completed: #{TimeEntry.completed.count}"
    puts "   - Active: #{TimeEntry.active.count}"
    puts "   - Anomalies: #{TimeEntry.anomalies.count}"
    puts "   - Total: #{TimeEntry.count}"
    puts "\nAnomalies:"
    puts "   - Unresolved: #{AnomalyLog.where(resolved: false).count}"
    puts "   - Resolved: #{AnomalyLog.where(resolved: true).count}"
    puts "   - Total: #{AnomalyLog.count}"
    puts "\nSchedules:"
    puts "   - Total: #{Schedule.count}"
    puts "=" * 60
    puts "\n"
  end
end
