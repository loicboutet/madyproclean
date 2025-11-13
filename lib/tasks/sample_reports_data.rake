namespace :reports do
  desc "Generate 50 sample reports in the database"
  task generate_reports: :environment do
    puts "\n📊 Generating 50 sample reports in database..."
    puts "=" * 60
    
    # Check if we have users
    if User.count.zero?
      puts "❌ ERROR: No users found!"
      puts "   Please run 'rails db:seed' first to create users."
      exit 1
    end
    
    # Get users who can generate reports (admins and managers)
    report_generators = User.where(role: ['admin', 'manager']).to_a
    if report_generators.empty?
      puts "❌ ERROR: No admin or manager users found!"
      puts "   Please run 'rails db:seed' first."
      exit 1
    end
    
    # Get sites for site-specific reports
    sites = Site.all.to_a
    
    # Clear existing demo reports
    Report.destroy_all
    puts "   ✓ Cleared existing reports"
    
    # Report types and their configurations
    report_types = [
      {
        type: 'monthly',
        weight: 15,  # 15 out of 50
        generator: ->(index, user, sites) {
          month_offset = index % 12
          start_date = Date.current.beginning_of_month - month_offset.months
          end_date = start_date.end_of_month
          
          {
            title: "Rapport Mensuel - #{I18n.l(start_date, format: '%B %Y')}",
            report_type: 'monthly',
            period_start: start_date,
            period_end: end_date,
            generated_at: start_date.next_month.beginning_of_month + rand(0..5).days + rand(8..10).hours,
            generated_by: user,
            status: ['completed', 'completed', 'completed', 'generating'].sample,
            description: 'Rapport mensuel complet des présences et heures travaillées pour tous les agents',
            total_hours: rand(3500.0..5000.0).round(2),
            total_agents: rand(100..150),
            total_sites: sites.count,
            filters_applied: { all_agents: true, all_sites: true },
            file_format: ['PDF', 'Excel', 'CSV'].sample,
            file_size: "#{rand(1.5..3.5).round(1)} MB"
          }
        }
      },
      {
        type: 'hr',
        weight: 8,
        generator: ->(index, user, sites) {
          quarter = index % 4
          year = Date.current.year - (index / 4)
          start_date = Date.new(year, (quarter * 3) + 1, 1)
          end_date = start_date + 2.months
          end_date = end_date.end_of_month
          
          total_absences = rand(50..120)
          total_agents = rand(100..150)
          absence_rate = (total_absences.to_f / total_agents * 100).round(2)
          
          {
            title: "Rapport RH - Taux d'Absence T#{quarter + 1} #{year}",
            report_type: 'hr',
            period_start: start_date,
            period_end: end_date,
            generated_at: end_date + rand(1..10).days + rand(9..16).hours,
            generated_by: user,
            status: 'completed',
            description: "Analyse des absences et taux de couverture d'équipe pour le trimestre #{quarter + 1}",
            total_absences: total_absences,
            absence_rate: absence_rate,
            coverage_rate: (100 - absence_rate).round(2),
            total_agents: total_agents,
            filters_applied: { absence_types: ['vacation', 'sick_leave', 'other'] },
            file_format: ['Excel', 'PDF'].sample,
            file_size: "#{rand(1.0..2.5).round(1)} MB"
          }
        }
      },
      {
        type: 'time_tracking',
        weight: 10,
        generator: ->(index, user, sites) {
          site = sites.sample
          month_offset = index % 6
          start_date = Date.current.beginning_of_month - month_offset.months
          end_date = start_date.end_of_month
          
          {
            title: "Rapport Temps Travaillé - #{site.name}",
            report_type: 'time_tracking',
            period_start: start_date,
            period_end: end_date,
            generated_at: end_date + rand(1..5).days + rand(9..15).hours,
            generated_by: user,
            status: 'completed',
            description: "Détail des heures travaillées pour #{site.name}",
            total_hours: rand(800.0..2500.0).round(2),
            total_agents: rand(20..60),
            total_sites: 1,
            site_name: site.name,
            site_code: site.code,
            filters_applied: { site_id: site.id },
            file_format: ['CSV', 'Excel'].sample,
            file_size: "#{rand(500..1500)} KB"
          }
        }
      },
      {
        type: 'scheduling',
        weight: 6,
        generator: ->(index, user, sites) {
          month_offset = index % 3
          start_date = (Date.current + month_offset.months).beginning_of_month
          end_date = start_date.end_of_month
          
          total_schedules = rand(350..500)
          scheduled = rand(250..total_schedules)
          
          {
            title: "Rapport Planification - #{I18n.l(start_date, format: '%B %Y')}",
            report_type: 'scheduling',
            period_start: start_date,
            period_end: end_date,
            generated_at: start_date - rand(3..10).days + rand(14..17).hours,
            generated_by: user,
            status: start_date > Date.current ? 'pending' : ['completed', 'generating'].sample,
            description: "Planification prévisionnelle des horaires pour #{I18n.l(start_date, format: '%B %Y')}",
            total_schedules: total_schedules,
            scheduled_count: scheduled,
            completed_count: start_date < Date.current ? rand(0..scheduled) : 0,
            missed_count: start_date < Date.current ? rand(0..20) : 0,
            filters_applied: { all_sites: true },
            file_format: 'PDF',
            file_size: start_date > Date.current ? nil : "#{rand(1.5..2.5).round(1)} MB"
          }
        }
      },
      {
        type: 'anomalies',
        weight: 5,
        generator: ->(index, user, sites) {
          month_offset = index % 6
          start_date = Date.current.beginning_of_month - month_offset.months
          end_date = start_date.end_of_month
          
          total_anomalies = rand(15..45)
          resolved = rand((total_anomalies * 0.6).to_i..total_anomalies)
          
          {
            title: "Rapport Anomalies - #{I18n.l(start_date, format: '%B %Y')}",
            report_type: 'anomalies',
            period_start: start_date,
            period_end: end_date,
            generated_at: end_date + rand(1..3).days + rand(10..14).hours,
            generated_by: user,
            status: 'completed',
            description: 'Liste des anomalies détectées et leur résolution',
            total_anomalies: total_anomalies,
            resolved_anomalies: resolved,
            unresolved_anomalies: total_anomalies - resolved,
            filters_applied: { severity: ['high', 'medium'] },
            file_format: ['Excel', 'CSV'].sample,
            file_size: "#{rand(400..900)} KB"
          }
        }
      },
      {
        type: 'payroll_export',
        weight: 3,
        generator: ->(index, user, sites) {
          month_offset = index % 12
          start_date = Date.current.beginning_of_month - month_offset.months
          end_date = start_date.end_of_month
          
          {
            title: "Rapport Export Paie - #{I18n.l(start_date, format: '%B %Y')}",
            report_type: 'payroll_export',
            period_start: start_date,
            period_end: end_date,
            generated_at: end_date + 1.day + 8.hours,
            generated_by: user,
            status: 'completed',
            description: 'Export des données pour le traitement de la paie',
            total_hours: rand(3500.0..5000.0).round(2),
            total_agents: rand(100..150),
            filters_applied: { active_agents: true },
            file_format: 'CSV',
            file_size: "#{rand(800..1500)} KB"
          }
        }
      },
      {
        type: 'site_performance',
        weight: 2,
        generator: ->(index, user, sites) {
          quarter = index % 4
          year = Date.current.year
          start_date = Date.new(year, (quarter * 3) + 1, 1)
          end_date = start_date + 2.months
          end_date = end_date.end_of_month
          
          {
            title: "Rapport Performance Sites - T#{quarter + 1} #{year}",
            report_type: 'site_performance',
            period_start: start_date,
            period_end: end_date,
            generated_at: start_date > Date.current ? nil : (end_date + rand(1..7).days),
            generated_by: user,
            status: start_date > Date.current ? 'pending' : ['completed', 'generating'].sample,
            description: 'Analyse de performance et utilisation de tous les sites',
            total_sites: sites.count,
            total_hours: rand(8000.0..15000.0).round(2),
            total_agents: rand(100..150),
            filters_applied: { all_sites: true },
            file_format: 'PDF',
            file_size: start_date > Date.current ? nil : "#{rand(2.0..4.0).round(1)} MB"
          }
        }
      },
      {
        type: 'agent_performance',
        weight: 1,
        generator: ->(index, user, sites) {
          quarter = index % 4
          year = Date.current.year
          start_date = Date.new(year, (quarter * 3) + 1, 1)
          end_date = start_date + 2.months
          end_date = end_date.end_of_month
          
          {
            title: "Rapport Performance Agents - T#{quarter + 1} #{year}",
            report_type: 'agent_performance',
            period_start: start_date,
            period_end: end_date,
            generated_at: start_date > Date.current ? nil : (end_date + rand(1..7).days),
            generated_by: user,
            status: start_date > Date.current ? 'pending' : 'completed',
            description: 'Analyse de performance individuelle des agents',
            total_agents: rand(100..150),
            total_hours: rand(8000.0..15000.0).round(2),
            filters_applied: { active_agents: true },
            file_format: 'Excel',
            file_size: start_date > Date.current ? nil : "#{rand(1.5..3.0).round(1)} MB"
          }
        }
      }
    ]
    
    # Generate reports based on weights
    reports_to_create = []
    report_types.each do |config|
      config[:weight].times do |i|
        reports_to_create << {
          config: config,
          index: i
        }
      end
    end
    
    # Shuffle to mix up the report types
    reports_to_create = reports_to_create.shuffle.first(50)
    
    created_count = 0
    reports_to_create.each_with_index do |item, idx|
      user = report_generators.sample
      report_data = item[:config][:generator].call(item[:index], user, sites)
      
      begin
        Report.create!(report_data)
        created_count += 1
        print "\r   Creating reports... #{created_count}/50"
      rescue => e
        puts "\n   ⚠️  Error creating report: #{e.message}"
      end
    end
    
    puts "\n"
    puts "=" * 60
    puts "✅ Report generation complete!"
    puts "\n📊 Summary:"
    puts "   - Total reports created: #{Report.count}"
    
    Report::REPORT_TYPES.each do |type|
      count = Report.where(report_type: type).count
      puts "   - #{type.titleize}: #{count}" if count > 0
    end
    
    puts "\n📈 By Status:"
    Report::STATUSES.each do |status|
      count = Report.where(status: status).count
      puts "   - #{status.titleize}: #{count}" if count > 0
    end
    
    puts "\n💡 Next steps:"
    puts "   1. Visit http://localhost:3000/admin/reports"
    puts "   2. Browse the generated reports"
    puts "   3. Use filters to view reports by type"
    puts "\n"
  end
  
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
