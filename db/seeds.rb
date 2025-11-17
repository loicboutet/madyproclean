# frozen_string_literal: true
# This file was auto-generated from the database using: rake db:export_to_seeds
# Generated at: 2025-11-17 12:34:15 UTC

puts '🌱 Starting seed import...'

# Safety: Only clear data in development and test environments
if Rails.env.development? || Rails.env.test?
  puts '🧹 Cleaning existing data...'
  ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = OFF')
  Report.delete_all
  AnomalyLog.delete_all
  Absence.delete_all
  Schedule.delete_all
  TimeEntry.delete_all
  Site.delete_all
  User.delete_all
  ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON')
  puts '  ✓ Cleaned'
end

# ==========================================
# USERS
# ==========================================
puts '👤 Creating users...'

# Create Admin
admin = User.create!(
  email: 'admin@madyproclean.com',
  password: 'pw54321',
  password_confirmation: 'pw54321',
  role: 'admin',
  first_name: 'Admin',
  last_name: 'User',
  employee_number: 'EMP001',
  active: true,
  phone_number: '+33123456789'
)
puts "  ✓ Created admin: #{admin.full_name}"

# Create Managers
manager1 = User.create!(
  email: 'manager1@madyproclean.com',
  password: 'pw54321',
  password_confirmation: 'pw54321',
  role: 'manager',
  first_name: 'Marie',
  last_name: 'Dubois',
  employee_number: 'EMP002',
  active: true,
  phone_number: '+33123456790'
)
puts "  ✓ Created manager: #{manager1.full_name}"

manager2 = User.create!(
  email: 'manager2@madyproclean.com',
  password: 'pw54321',
  password_confirmation: 'pw54321',
  role: 'manager',
  first_name: 'Pierre',
  last_name: 'Martin',
  employee_number: 'EMP003',
  active: true,
  phone_number: '+33123456791'
)
puts "  ✓ Created manager: #{manager2.full_name}"

# Create Agents
agent1 = User.create!(
  email: 'agent1@madyproclean.com',
  password: 'pw54321',
  password_confirmation: 'pw54321',
  role: 'agent',
  first_name: 'Sophie',
  last_name: 'Laurent',
  employee_number: 'EMP004',
  active: true,
  phone_number: '+33123456792',
  manager: manager1
)
puts "  ✓ Created agent: #{agent1.full_name} (managed by #{manager1.full_name})"

agent2 = User.create!(
  email: 'agent2@madyproclean.com',
  password: 'pw54321',
  password_confirmation: 'pw54321',
  role: 'agent',
  first_name: 'Lucas',
  last_name: 'Bernard',
  employee_number: 'EMP005',
  active: true,
  phone_number: '+33123456793',
  manager: manager1
)
puts "  ✓ Created agent: #{agent2.full_name} (managed by #{manager1.full_name})"

agent3 = User.create!(
  email: 'agent3@madyproclean.com',
  password: 'pw54321',
  password_confirmation: 'pw54321',
  role: 'agent',
  first_name: 'Emma',
  last_name: 'Petit',
  employee_number: 'EMP006',
  active: true,
  phone_number: '+33123456794',
  manager: manager2
)
puts "  ✓ Created agent: #{agent3.full_name} (managed by #{manager2.full_name})"

# ==========================================
# SITES
# ==========================================
puts '🏢 Creating sites...'

# Site names and types
site_types = [
  { type: 'Office', prefix: 'OFF' },
  { type: 'Warehouse', prefix: 'WH' },
  { type: 'Retail', prefix: 'RET' },
  { type: 'Medical', prefix: 'MED' },
  { type: 'School', prefix: 'SCH' },
  { type: 'Hotel', prefix: 'HTL' },
  { type: 'Restaurant', prefix: 'RST' },
  { type: 'Factory', prefix: 'FCT' }
]

streets = ['Rue de la Paix', 'Avenue des Champs', 'Boulevard Haussmann', 'Rue de la Santé', 
           'Avenue Montaigne', 'Rue du Faubourg', 'Boulevard Saint-Germain', 'Rue de Rivoli',
           'Avenue Victor Hugo', 'Rue Lafayette']

arrondissements = ['75001', '75008', '75014', '75016', '93200', '92100', '94300', '91000']

sites = []
25.times do |i|
  site_type = site_types[i % site_types.length]
  site = Site.create!(
    name: "#{site_type[:type]} Building #{(i / site_types.length) + 1}",
    code: "#{site_type[:prefix]}-#{(i + 1).to_s.rjust(3, '0')}",
    address: "#{rand(1..999)} #{streets[i % streets.length]}, #{arrondissements[i % arrondissements.length]} Paris, France",
    description: "Professional cleaning site - #{site_type[:type]} facility",
    active: i < 23 # Make 2 inactive for testing
  )
  sites << site
  puts "  ✓ Created site: #{site.name} (#{site.code})"
end

# Store first 4 sites for backward compatibility with existing references
site1 = sites[0]
site2 = sites[1]
site3 = sites[2]
site4 = sites[3]

# ==========================================
# SCHEDULES
# ==========================================
puts '📅 Creating schedules...'

schedules_count = 0

# Create schedules for the past 7 days
7.times do |i|
  date = (Date.today - (7 - i).days)
  
  # Agent 1 at Site 1
  Schedule.create!(
    user: agent1,
    site: site1,
    scheduled_date: date,
    start_time: '08:00',
    end_time: '16:00',
    status: 'completed',
    created_by: manager1,
    notes: 'Regular morning shift'
  )
  schedules_count += 1
  
  # Agent 2 at Site 2
  Schedule.create!(
    user: agent2,
    site: site2,
    scheduled_date: date,
    start_time: '09:00',
    end_time: '17:00',
    status: 'completed',
    created_by: manager1,
    notes: 'Standard day shift'
  )
  schedules_count += 1
  
  # Agent 3 at Site 3
  Schedule.create!(
    user: agent3,
    site: site3,
    scheduled_date: date,
    start_time: '14:00',
    end_time: '22:00',
    status: 'completed',
    created_by: manager2,
    notes: 'Evening shift'
  )
  schedules_count += 1
end

# Create schedules for next 14 days
14.times do |i|
  date = Date.today + (i + 1).days
  
  # Rotate agents across sites
  case i % 3
  when 0
    Schedule.create!(
      user: agent1,
      site: site1,
      scheduled_date: date,
      start_time: '08:00',
      end_time: '16:00',
      status: 'scheduled',
      created_by: manager1
    )
    Schedule.create!(
      user: agent2,
      site: site2,
      scheduled_date: date,
      start_time: '09:00',
      end_time: '17:00',
      status: 'scheduled',
      created_by: manager1
    )
    schedules_count += 2
  when 1
    Schedule.create!(
      user: agent3,
      site: site3,
      scheduled_date: date,
      start_time: '14:00',
      end_time: '22:00',
      status: 'scheduled',
      created_by: manager2
    )
    Schedule.create!(
      user: agent1,
      site: site4,
      scheduled_date: date,
      start_time: '06:00',
      end_time: '14:00',
      status: 'scheduled',
      created_by: manager1
    )
    schedules_count += 2
  when 2
    Schedule.create!(
      user: agent2,
      site: site3,
      scheduled_date: date,
      start_time: '10:00',
      end_time: '18:00',
      status: 'scheduled',
      created_by: manager1
    )
    Schedule.create!(
      user: agent3,
      site: site4,
      scheduled_date: date,
      start_time: '08:00',
      end_time: '16:00',
      status: 'scheduled',
      created_by: manager2
    )
    schedules_count += 2
  end
end

puts "  ✓ Created #{schedules_count} schedules"

# ==========================================
# TIME ENTRIES
# ==========================================
puts '⏰ Creating time entries...'

time_entries_count = 0
agents = [agent1, agent2, agent3]

# Create 50 time entries spread over past 30 days
50.times do |i|
  days_ago = rand(1..30)
  date = Date.today - days_ago.days
  agent = agents[i % agents.length]
  site = sites[i % sites.length]
  
  # Most entries are completed, few are active or anomaly
  is_active = i == 0 # Only first one is active
  is_anomaly = (i % 15 == 0) && !is_active
  is_corrected = (i % 10 == 0) && !is_active && !is_anomaly
  
  # Generate valid start and end hours (ensuring end_hour doesn't exceed 23)
  start_hour = [6, 7, 8, 9, 10, 14][rand(0..5)]
  duration_hours = [7, 8, 9].sample # Standard shift durations
  end_hour = [start_hour + duration_hours, 22].min # Cap at 22 to avoid going to next day
  
  entry = TimeEntry.create!(
    user: agent,
    site: site,
    clocked_in_at: is_active ? (Time.now - 3.hours) : DateTime.new(date.year, date.month, date.day, start_hour, rand(0..59), 0),
    clocked_out_at: is_active ? nil : DateTime.new(date.year, date.month, date.day, end_hour, rand(0..59), 0),
    status: is_active ? 'active' : (is_anomaly ? 'anomaly' : 'completed'),
    ip_address_in: "192.168.#{rand(1..10)}.#{rand(100..200)}",
    ip_address_out: is_active ? nil : "192.168.#{rand(1..10)}.#{rand(100..200)}",
    manually_corrected: is_corrected,
    corrected_by: is_corrected ? [manager1, manager2, admin].sample : nil,
    corrected_at: is_corrected ? (days_ago - 1).days.ago : nil,
    notes: is_corrected ? 'Time corrected by manager' : (is_anomaly ? 'Flagged for anomaly' : nil)
  )
  
  unless is_active
    entry.update!(duration_minutes: ((entry.clocked_out_at - entry.clocked_in_at) / 60).to_i)
  end
  
  time_entries_count += 1
end

puts "  ✓ Created #{time_entries_count} time entries"

# ==========================================
# ABSENCES
# ==========================================
puts '🏥 Creating absences...'

absences_count = 0

# Approved vacation for Agent 1
Absence.create!(
  user: agent1,
  absence_type: 'vacation',
  start_date: Date.today + 20.days,
  end_date: Date.today + 24.days,
  status: 'approved',
  reason: 'Family vacation',
  created_by: manager1
)
absences_count += 1

# Pending sick leave for Agent 2
Absence.create!(
  user: agent2,
  absence_type: 'sick',
  start_date: Date.today + 2.days,
  end_date: Date.today + 3.days,
  status: 'pending',
  reason: 'Medical appointment',
  created_by: agent2
)
absences_count += 1

# Rejected other leave for Agent 3
Absence.create!(
  user: agent3,
  absence_type: 'other',
  start_date: Date.today + 1.day,
  end_date: Date.today + 1.day,
  status: 'rejected',
  reason: 'Personal matters',
  created_by: manager2
)
absences_count += 1

# Approved sick leave from the past
Absence.create!(
  user: agent3,
  absence_type: 'sick',
  start_date: Date.today - 10.days,
  end_date: Date.today - 8.days,
  status: 'approved',
  reason: 'Flu',
  created_by: manager2
)
absences_count += 1

puts "  ✓ Created #{absences_count} absences"

# ==========================================
# ANOMALY LOGS
# ==========================================
puts '🚨 Creating anomaly logs...'

anomalies_count = 0

anomaly_types = ['missed_clock_in', 'missed_clock_out', 'over_24h', 'multiple_active', 'schedule_mismatch']
severities = ['low', 'medium', 'high']
descriptions = {
  'missed_clock_in' => 'Agent did not clock in at scheduled time',
  'missed_clock_out' => 'Agent forgot to clock out at end of shift',
  'over_24h' => 'Time entry active for more than 24 hours',
  'multiple_active' => 'Multiple active entries detected from different locations',
  'schedule_mismatch' => 'Agent clocked in but no schedule was found'
}

# Get some time entries and schedules for linking
time_entries_for_anomalies = TimeEntry.limit(30).to_a
schedules_for_anomalies = Schedule.limit(20).to_a

# Create 50 anomaly logs
50.times do |i|
  days_ago = rand(1..30)
  anomaly_type = anomaly_types[i % anomaly_types.length]
  severity = severities[rand(0..2)]
  agent = agents[i % agents.length]
  is_resolved = i % 3 != 0 # About 2/3 are resolved
  
  # Link to time entry or schedule based on type
  time_entry_link = ['missed_clock_out', 'over_24h', 'multiple_active'].include?(anomaly_type) ? time_entries_for_anomalies[i % time_entries_for_anomalies.length] : nil
  schedule_link = ['missed_clock_in', 'schedule_mismatch'].include?(anomaly_type) ? schedules_for_anomalies[i % schedules_for_anomalies.length] : nil
  
  AnomalyLog.create!(
    anomaly_type: anomaly_type,
    severity: severity,
    user: agent,
    time_entry: time_entry_link,
    schedule: schedule_link,
    description: "#{descriptions[anomaly_type]} - Case ##{i + 1}",
    resolved: is_resolved,
    resolved_by: is_resolved ? [manager1, manager2, admin].sample : nil,
    resolved_at: is_resolved ? (days_ago - rand(1..5)).days.ago : nil,
    resolution_notes: is_resolved ? ['Issue resolved after investigation', 'Corrected by manager', 'Agent confirmed', 'False alarm'].sample : nil
  )
  anomalies_count += 1
end

puts "  ✓ Created #{anomalies_count} anomaly logs"

# ==========================================
# REPORTS
# ==========================================
puts '📊 Creating reports...'

reports_count = 0

report_types = ['attendance', 'time_entry', 'anomaly', 'schedule']
period_types = ['daily', 'weekly', 'monthly', 'custom']
statuses = ['pending', 'completed']
file_formats = ['PDF', 'Excel', 'CSV']
generators = [admin, manager1, manager2]

months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

# Create 30 reports
30.times do |i|
  days_ago = rand(1..90)
  report_type = report_types[i % report_types.length]
  period_type = period_types[i % period_types.length]
  status = statuses[i % 5 == 0 ? 0 : 1] # 20% pending, 80% completed
  generator = generators[i % generators.length]
  file_format = file_formats[rand(0..2)]
  
  # Calculate period dates based on period_type
  case period_type
  when 'daily'
    period_start = Date.today - days_ago.days
    period_end = period_start
  when 'weekly'
    period_start = Date.today - days_ago.days - 6.days
    period_end = Date.today - days_ago.days
  when 'monthly'
    month_offset = i % 12
    period_start = Date.new(2025, 12 - month_offset, 1)
    period_end = period_start.end_of_month
  when 'custom'
    period_start = Date.today - (days_ago + 14).days
    period_end = Date.today - days_ago.days
  end
  
  # Generate title based on type and period
  title = case report_type
  when 'attendance'
    "Attendance Report - #{period_type.capitalize} ##{i + 1}"
  when 'time_entry'
    "Time Entries Report - #{period_type.capitalize} Period"
  when 'anomaly'
    "Anomalies Analysis - Week #{i + 1}"
  when 'schedule'
    "Schedule Report - #{period_start.strftime('%B %Y')}"
  end
  
  Report.create!(
    title: title,
    report_type: report_type,
    period_type: period_type,
    period_start: period_start,
    period_end: period_end,
    generated_at: status == 'completed' ? (Time.now - days_ago.days) : nil,
    generated_by: generator,
    status: status,
    description: "#{report_type.titleize} report for #{period_type} period covering #{period_start.strftime('%Y-%m-%d')} to #{period_end.strftime('%Y-%m-%d')}",
    filters_applied: { 'generated_by' => generator.full_name, 'type' => report_type }.to_json,
    file_format: status == 'completed' ? file_format : nil,
    file_size: status == 'completed' ? "#{rand(100..2000)} KB" : nil
  )
  reports_count += 1
end

puts "  ✓ Created #{reports_count} reports"

# ==========================================
# SUMMARY
# ==========================================
puts ''
puts '✅ Seed import completed successfully!'
puts ''
puts '📊 Summary:'
puts "  - Users: #{User.count}"
puts "    * Admins: #{User.admins.count}"
puts "    * Managers: #{User.managers.count}"
puts "    * Agents: #{User.agents.count}"
puts "  - Sites: #{Site.count}"
puts "  - Time Entries: #{TimeEntry.count}"
puts "  - Schedules: #{Schedule.count}"
puts "  - Absences: #{Absence.count}"
puts "  - Anomaly Logs: #{AnomalyLog.count}"
puts "  - Reports: #{Report.count}"
puts ''
puts '🔑 Login Credentials:'
puts '  All users have password: pw54321'
puts ''
puts '  Admin:'
puts '    Email: admin@madyproclean.com'
puts ''
puts '  Managers:'
puts '    Email: manager1@madyproclean.com (Marie Dubois)'
puts '    Email: manager2@madyproclean.com (Pierre Martin)'
puts ''
puts '  Agents:'
puts '    Email: agent1@madyproclean.com (Sophie Laurent - managed by Marie)'
puts '    Email: agent2@madyproclean.com (Lucas Bernard - managed by Marie)'
puts '    Email: agent3@madyproclean.com (Emma Petit - managed by Pierre)'
puts ''
