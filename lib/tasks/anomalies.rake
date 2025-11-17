namespace :anomalies do
  desc "Detect and create anomaly logs for missed clock-outs"
  task detect_missed_clock_outs: :environment do
    puts "Detecting missed clock-outs..."
    count = 0
    
    TimeEntry.detect_missed_clock_outs
    count = AnomalyLog.anomaly_type_missed_clock_out.where('created_at > ?', 1.hour.ago).count
    
    puts "Created #{count} anomaly log(s) for missed clock-outs"
  end

  desc "Detect and create anomaly logs for time entries over 24 hours"
  task detect_over_24h: :environment do
    puts "Detecting time entries over 24 hours..."
    count = 0
    
    TimeEntry.over_24_hours.find_each do |entry|
      unless entry.anomaly_logs.anomaly_type_over_24h.exists?
        AnomalyLog.create_for_over_24h(entry)
        entry.mark_as_anomaly_status
        count += 1
      end
    end
    
    puts "Created #{count} anomaly log(s) for over 24h entries"
  end

  desc "Detect and create anomaly logs for schedule mismatches"
  task detect_schedule_mismatches: :environment do
    puts "Detecting schedule mismatches..."
    
    Schedule.detect_schedule_mismatches
    count = AnomalyLog.anomaly_type_schedule_mismatch.where('created_at > ?', 1.hour.ago).count
    
    puts "Created #{count} anomaly log(s) for schedule mismatches"
  end

  desc "Detect and create anomaly logs for missed clock-ins"
  task detect_missed_clock_ins: :environment do
    puts "Detecting missed clock-ins..."
    
    Schedule.detect_missed_clock_ins
    count = AnomalyLog.anomaly_type_missed_clock_in.where('created_at > ?', 1.hour.ago).count
    
    puts "Created #{count} anomaly log(s) for missed clock-ins"
  end

  desc "Detect and create anomaly logs for multiple active entries (fraud detection)"
  task detect_multiple_active: :environment do
    puts "Detecting multiple active entries (fraud detection)..."
    
    TimeEntry.detect_multiple_active_entries
    count = AnomalyLog.anomaly_type_multiple_active.where('created_at > ?', 1.hour.ago).count
    
    puts "Created #{count} anomaly log(s) for multiple active entries"
  end

  desc "Run all anomaly detection tasks"
  task detect_all: :environment do
    puts "=" * 60
    puts "Running all anomaly detection tasks..."
    puts "=" * 60
    puts ""
    
    Rake::Task['anomalies:detect_over_24h'].invoke
    puts ""
    
    Rake::Task['anomalies:detect_missed_clock_outs'].invoke
    puts ""
    
    Rake::Task['anomalies:detect_schedule_mismatches'].invoke
    puts ""
    
    Rake::Task['anomalies:detect_missed_clock_ins'].invoke
    puts ""
    
    Rake::Task['anomalies:detect_multiple_active'].invoke
    puts ""
    
    puts "=" * 60
    puts "All anomaly detection tasks completed!"
    puts "Total anomalies: #{AnomalyLog.count} (#{AnomalyLog.unresolved.count} unresolved)"
    puts "=" * 60
  end

  desc "Display summary of all anomalies"
  task summary: :environment do
    puts "=" * 60
    puts "ANOMALY SUMMARY"
    puts "=" * 60
    puts ""
    
    puts "Total Anomalies: #{AnomalyLog.count}"
    puts "  - Unresolved: #{AnomalyLog.unresolved.count}"
    puts "  - Resolved: #{AnomalyLog.resolved.count}"
    puts ""
    
    puts "By Type:"
    AnomalyLog.anomaly_types.each do |type, _|
      count = AnomalyLog.where(anomaly_type: type).count
      unresolved = AnomalyLog.where(anomaly_type: type).unresolved.count
      puts "  - #{type.titleize}: #{count} (#{unresolved} unresolved)"
    end
    puts ""
    
    puts "By Severity:"
    AnomalyLog.severities.each do |severity, _|
      count = AnomalyLog.where(severity: severity).count
      unresolved = AnomalyLog.where(severity: severity).unresolved.count
      puts "  - #{severity.titleize}: #{count} (#{unresolved} unresolved)"
    end
    puts ""
    
    puts "=" * 60
  end

  desc "Generate 60 sample anomalies based on existing records"
  task generate_samples: :environment do
    puts "=" * 60
    puts "GENERATING SAMPLE ANOMALIES"
    puts "=" * 60
    puts ""
    
    # Fetch existing records
    users = User.agents.active.to_a
    admins = User.where(role: ['admin', 'manager']).active.to_a
    time_entries = TimeEntry.all.to_a
    schedules = Schedule.all.to_a
    sites = Site.active.to_a
    
    # Validate we have enough records
    if users.empty?
      puts "ERROR: No active agent users found. Please create some users first."
      exit 1
    end
    
    if admins.empty?
      puts "ERROR: No admin/manager users found. Please create some admin users first."
      exit 1
    end
    
    if time_entries.empty?
      puts "WARNING: No time entries found. Some anomaly types will be skipped."
    end
    
    if schedules.empty?
      puts "WARNING: No schedules found. Some anomaly types will be skipped."
    end
    
    if sites.empty?
      puts "ERROR: No active sites found. Please create some sites first."
      exit 1
    end
    
    puts "Found #{users.count} users, #{admins.count} admins, #{time_entries.count} time entries, #{schedules.count} schedules, #{sites.count} sites"
    puts ""
    
    created_count = 0
    resolution_notes = [
      "Correction manuelle effectuée - oubli de pointage",
      "Agent contacté et situation clarifiée",
      "Anomalie confirmée - doublon supprimé",
      "Agent en absence maladie non déclarée - absence ajoutée rétroactivement",
      "Pointage manuel corrigé par le superviseur",
      "Erreur système corrigée",
      "Agent a oublié de pointer - rappel envoyé"
    ]
    
    # Generate anomalies in transaction
    ActiveRecord::Base.transaction do
      # 1. Missed clock-in anomalies (12 anomalies)
      12.times do |i|
        next if schedules.empty?
        
        schedule = schedules.sample
        user = schedule.user
        resolved = i < 5 # First 5 resolved
        severity = ['low', 'low', 'medium'].sample
        created_at = rand(1..30).days.ago
        
        anomaly = AnomalyLog.create!(
          anomaly_type: :missed_clock_in,
          severity: severity,
          user: user,
          schedule: schedule,
          description: "Aucun pointage d'entrée enregistré pour l'horaire planifié du #{schedule.scheduled_date.strftime('%d/%m/%Y')} sur le site #{schedule.site.name}",
          resolved: resolved,
          resolved_by: resolved ? admins.sample : nil,
          resolved_at: resolved ? created_at + rand(1..48).hours : nil,
          resolution_notes: resolved ? resolution_notes.sample : nil,
          created_at: created_at,
          updated_at: created_at
        )
        created_count += 1
      end
      
      # 2. Missed clock-out anomalies (12 anomalies)
      12.times do |i|
        next if time_entries.empty?
        
        time_entry = time_entries.sample
        user = time_entry.user
        site = time_entry.site
        resolved = i < 8 # First 8 resolved
        severity = ['medium', 'medium', 'high'].sample
        created_at = rand(1..30).days.ago
        
        anomaly = AnomalyLog.create!(
          anomaly_type: :missed_clock_out,
          severity: severity,
          user: user,
          time_entry: time_entry,
          description: "Agent n'a pas enregistré sa sortie du site #{site.name} le #{time_entry.clocked_in_at.strftime('%d/%m/%Y')}",
          resolved: resolved,
          resolved_by: resolved ? admins.sample : nil,
          resolved_at: resolved ? created_at + rand(1..72).hours : nil,
          resolution_notes: resolved ? resolution_notes.sample : nil,
          created_at: created_at,
          updated_at: created_at
        )
        created_count += 1
      end
      
      # 3. Over 24h anomalies (12 anomalies)
      12.times do |i|
        next if time_entries.empty?
        
        time_entry = time_entries.sample
        user = time_entry.user
        site = time_entry.site
        resolved = i < 9 # First 9 resolved
        severity = :high
        hours = rand(25..48)
        created_at = rand(1..30).days.ago
        
        anomaly = AnomalyLog.create!(
          anomaly_type: :over_24h,
          severity: severity,
          user: user,
          time_entry: time_entry,
          description: "Pointage actif depuis plus de 24 heures (#{hours}h) sur le site #{site.name}",
          resolved: resolved,
          resolved_by: resolved ? admins.sample : nil,
          resolved_at: resolved ? created_at + rand(1..24).hours : nil,
          resolution_notes: resolved ? resolution_notes.sample : nil,
          created_at: created_at,
          updated_at: created_at
        )
        created_count += 1
      end
      
      # 4. Multiple active anomalies (12 anomalies)
      12.times do |i|
        user = users.sample
        time_entry = time_entries.empty? ? nil : time_entries.sample
        resolved = i < 10 # First 10 resolved
        severity = :high
        created_at = rand(1..30).days.ago
        
        anomaly = AnomalyLog.create!(
          anomaly_type: :multiple_active,
          severity: severity,
          user: user,
          time_entry: time_entry,
          description: "Détection de plusieurs pointages actifs simultanés depuis des adresses IP différentes pour #{user.full_name}",
          resolved: resolved,
          resolved_by: resolved ? admins.sample : nil,
          resolved_at: resolved ? created_at + rand(1..12).hours : nil,
          resolution_notes: resolved ? resolution_notes.sample : nil,
          created_at: created_at,
          updated_at: created_at
        )
        created_count += 1
      end
      
      # 5. Schedule mismatch anomalies (12 anomalies)
      12.times do |i|
        next if schedules.empty?
        
        schedule = schedules.sample
        user = schedule.user
        site = schedule.site
        resolved = i < 6 # First 6 resolved
        severity = :medium
        created_at = rand(1..30).days.ago
        
        anomaly = AnomalyLog.create!(
          anomaly_type: :schedule_mismatch,
          severity: severity,
          user: user,
          schedule: schedule,
          description: "Agent n'a pas pointé alors qu'il était planifié sur le site #{site.name} le #{schedule.scheduled_date.strftime('%d/%m/%Y')}",
          resolved: resolved,
          resolved_by: resolved ? admins.sample : nil,
          resolved_at: resolved ? created_at + rand(2..96).hours : nil,
          resolution_notes: resolved ? resolution_notes.sample : nil,
          created_at: created_at,
          updated_at: created_at
        )
        created_count += 1
      end
    end
    
    puts ""
    puts "=" * 60
    puts "Successfully created #{created_count} sample anomalies!"
    puts "=" * 60
    puts ""
    
    # Display summary
    Rake::Task['anomalies:summary'].invoke
  end
end
