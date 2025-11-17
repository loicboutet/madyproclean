# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting seed process..."

# Clear existing data (in development only)
if Rails.env.development?
  puts "🧹 Cleaning existing data..."
  # Disable foreign key checks temporarily for SQLite
  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")
  Schedule.delete_all
  TimeEntry.delete_all
  Site.delete_all
  User.delete_all
  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")
end

# Create Admin Users
puts "👑 Creating admin users..."
admin1 = User.create!(
  email: 'admin@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Sophie',
  last_name: 'Martin',
  role: 'admin',
  phone_number: '+33 6 12 34 56 78',
  active: true
)
puts "  ✓ Created admin: #{admin1.email}"

admin2 = User.create!(
  email: 'director@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Pierre',
  last_name: 'Dubois',
  role: 'admin',
  phone_number: '+33 6 23 45 67 89',
  active: true
)
puts "  ✓ Created admin: #{admin2.email}"

# Create Manager Users
puts "👔 Creating manager users..."
manager1 = User.create!(
  email: 'manager1@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Marie',
  last_name: 'Leroy',
  role: 'manager',
  phone_number: '+33 6 34 56 78 90',
  active: true
)
puts "  ✓ Created manager: #{manager1.email}"

manager2 = User.create!(
  email: 'manager2@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Thomas',
  last_name: 'Bernard',
  role: 'manager',
  phone_number: '+33 6 45 67 89 01',
  active: true
)
puts "  ✓ Created manager: #{manager2.email}"

manager3 = User.create!(
  email: 'manager3@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Claire',
  last_name: 'Moreau',
  role: 'manager',
  phone_number: '+33 6 56 78 90 12',
  active: true
)
puts "  ✓ Created manager: #{manager3.email}"

# Create Agent Users
puts "👷 Creating agent users..."

# Agents for manager1
agent1 = User.create!(
  email: 'agent1@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Lucas',
  last_name: 'Petit',
  role: 'agent',
  employee_number: 'EMP001',
  phone_number: '+33 6 67 89 01 23',
  manager: manager1,
  active: true
)
puts "  ✓ Created agent: #{agent1.email} (managed by #{manager1.full_name})"

agent2 = User.create!(
  email: 'agent2@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Emma',
  last_name: 'Roux',
  role: 'agent',
  employee_number: 'EMP002',
  phone_number: '+33 6 78 90 12 34',
  manager: manager1,
  active: true
)
puts "  ✓ Created agent: #{agent2.email} (managed by #{manager1.full_name})"

# Agents for manager2
agent3 = User.create!(
  email: 'agent3@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Hugo',
  last_name: 'Blanc',
  role: 'agent',
  employee_number: 'EMP003',
  phone_number: '+33 6 89 01 23 45',
  manager: manager2,
  active: true
)
puts "  ✓ Created agent: #{agent3.email} (managed by #{manager2.full_name})"

agent4 = User.create!(
  email: 'agent4@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Léa',
  last_name: 'Garnier',
  role: 'agent',
  employee_number: 'EMP004',
  phone_number: '+33 6 90 12 34 56',
  manager: manager2,
  active: true
)
puts "  ✓ Created agent: #{agent4.email} (managed by #{manager2.full_name})"

# Agents for manager3
agent5 = User.create!(
  email: 'agent5@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Arthur',
  last_name: 'Faure',
  role: 'agent',
  employee_number: 'EMP005',
  phone_number: '+33 6 01 23 45 67',
  manager: manager3,
  active: true
)
puts "  ✓ Created agent: #{agent5.email} (managed by #{manager3.full_name})"

# Create one inactive user for testing
inactive_agent = User.create!(
  email: 'inactive@madyproclean.fr',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Inactif',
  last_name: 'Utilisateur',
  role: 'agent',
  employee_number: 'EMP099',
  phone_number: '+33 6 00 00 00 00',
  manager: manager1,
  active: false
)
puts "  ✓ Created inactive agent: #{inactive_agent.email}"

# Create Sites
puts "🏢 Creating nuclear sites..."
if Rails.env.development?
  Site.delete_all
end

sites = [
  {
    name: 'Centrale Nucléaire de Gravelines',
    code: 'GRA-001',
    address: 'Avenue des Dunes, 59820 Gravelines',
    description: 'Site nucléaire Nord de la France'
  },
  {
    name: 'Site Nucléaire Paris Nord',
    code: 'SPN-002',
    address: '123 Rue de la République, 75001 Paris',
    description: 'Centre de contrôle régional Paris'
  },
  {
    name: 'Centrale de Cattenom',
    code: 'CAT-003',
    address: 'Route de Cattenom, 57570 Cattenom',
    description: 'Centrale nucléaire de Lorraine'
  },
  {
    name: 'Site de Flamanville',
    code: 'FLA-004',
    address: 'BP 4, 50340 Flamanville',
    description: 'Site nucléaire de la Manche'
  },
  {
    name: 'Centrale de Paluel',
    code: 'PAL-005',
    address: 'Route de Paluel, 76450 Veulettes-sur-Mer',
    description: 'Site nucléaire de Seine-Maritime'
  },
  {
    name: 'Centre de Maintenance Lyon',
    code: 'CML-006',
    address: '456 Avenue du Rhône, 69001 Lyon',
    description: 'Centre technique régional'
  },
  {
    name: 'Station de Contrôle Marseille',
    code: 'SCM-007',
    address: '789 Boulevard Maritime, 13001 Marseille',
    description: 'Station de contrôle Sud'
  },
  {
    name: 'Base Technique Toulouse',
    code: 'BTT-008',
    address: '321 Rue Capitole, 31000 Toulouse',
    description: 'Base technique Sud-Ouest'
  }
]

created_sites = sites.map do |site_data|
  site = Site.create!(site_data)
  puts "  ✓ Created site: #{site.name} (#{site.code})"
  site
end

# Create additional agents for realistic time entries
puts "👷 Creating additional agent users..."
additional_agents = []

# Generate more agents (total should be around 20-25 for 100 time entries)
(6..25).each do |i|
  first_names = ['Antoine', 'Julie', 'Nicolas', 'Sophie', 'Julien', 'Camille', 'Maxime', 'Laura', 
                 'Alexandre', 'Manon', 'Romain', 'Chloé', 'Vincent', 'Margaux', 'Benjamin', 
                 'Sarah', 'Florian', 'Marine', 'Quentin', 'Mathilde']
  last_names = ['Dupont', 'Martin', 'Bernard', 'Dubois', 'Thomas', 'Robert', 'Richard', 'Petit',
                'Durand', 'Leroy', 'Moreau', 'Simon', 'Laurent', 'Lefebvre', 'Michel', 'Garcia',
                'David', 'Bertrand', 'Roux', 'Vincent']
  
  manager = [manager1, manager2, manager3].sample
  
  agent = User.create!(
    email: "agent#{i}@madyproclean.fr",
    password: 'password123',
    password_confirmation: 'password123',
    first_name: first_names[(i-6) % first_names.length],
    last_name: last_names[(i-6) % last_names.length],
    role: 'agent',
    employee_number: sprintf('EMP%03d', i),
    phone_number: "+33 6 #{rand(10..99)} #{rand(10..99)} #{rand(10..99)} #{rand(10..99)}",
    manager: manager,
    active: true
  )
  additional_agents << agent
  puts "  ✓ Created agent: #{agent.email} (managed by #{manager.full_name})"
end

# Combine all agents
all_agents = [agent1, agent2, agent3, agent4, agent5] + additional_agents

# Create Time Entries
puts "⏰ Creating time entries (100 records)..."
if Rails.env.development?
  TimeEntry.delete_all
end

ip_addresses = ['192.168.1.45', '192.168.1.78', '192.168.1.92', '192.168.1.120', '192.168.1.88', '10.0.0.15', '10.0.0.22']
user_agents = [
  'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15',
  'Mozilla/5.0 (Android 12; Mobile) AppleWebKit/537.36',
  'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15',
  'Mozilla/5.0 (Android 13; Mobile) AppleWebKit/537.36'
]

# Generate 100 time entries over the last 30 days
time_entries_count = 0
target_entries = 100

# Generate completed entries (85% - 85 entries)
(1..85).each do |i|
  agent = all_agents.sample
  site = created_sites.sample
  days_ago = rand(1..30)
  
  # Random start time between 7 AM and 9 AM
  clock_in = days_ago.days.ago.beginning_of_day + rand(7..9).hours + rand(0..59).minutes
  
  # Work duration between 7-9 hours
  duration_hours = rand(7..9)
  duration_minutes = rand(0..59)
  clock_out = clock_in + duration_hours.hours + duration_minutes.minutes
  
  entry = TimeEntry.create!(
    user: agent,
    site: site,
    clocked_in_at: clock_in,
    clocked_out_at: clock_out,
    status: 'completed',
    ip_address_in: ip_addresses.sample,
    ip_address_out: ip_addresses.sample,
    user_agent_in: user_agents.sample,
    user_agent_out: user_agents.sample
  )
  time_entries_count += 1
  
  # Add some manual corrections (about 10% of completed entries)
  if rand(1..10) == 1
    entry.update!(
      manually_corrected: true,
      corrected_by: admin1,
      corrected_at: entry.clocked_out_at + 2.hours,
      notes: 'Correction manuelle: oubli de pointage de départ'
    )
  end
end

puts "  ✓ Created #{time_entries_count} completed time entries"

# Generate active entries (10% - 10 entries)
# Select 10 random agents who don't have active entries yet
agents_for_active = all_agents.sample(10)
agents_for_active.each do |agent|
  site = created_sites.sample
  
  # Active entries from today, varying times
  hours_ago = rand(1..8)
  clock_in = hours_ago.hours.ago
  
  TimeEntry.create!(
    user: agent,
    site: site,
    clocked_in_at: clock_in,
    clocked_out_at: nil,
    status: 'active',
    ip_address_in: ip_addresses.sample,
    user_agent_in: user_agents.sample
  )
  time_entries_count += 1
end

puts "  ✓ Created 10 active time entries"

# Generate anomaly entries (5% - 5 entries)
(1..5).each do |i|
  agent = all_agents.sample
  site = created_sites.sample
  
  # Anomaly: entries from 2-5 days ago that were never closed
  days_ago = rand(2..5)
  clock_in = days_ago.days.ago.beginning_of_day + rand(7..9).hours
  
  TimeEntry.create!(
    user: agent,
    site: site,
    clocked_in_at: clock_in,
    clocked_out_at: nil,
    status: 'anomaly',
    ip_address_in: ip_addresses.sample,
    user_agent_in: user_agents.sample,
    notes: 'Anomalie détectée: pas de pointage de départ depuis plus de 24h'
  )
  time_entries_count += 1
end

puts "  ✓ Created 5 anomaly time entries"

# Create Schedules
puts "📅 Creating schedules..."
if Rails.env.development?
  Schedule.delete_all
end

created_schedules = []

# Create schedules for the past 30 days (mix of completed, missed, and some with replacements)
schedules_count = 0

# Strategy: Create schedules that match some completed time entries (to show schedule adherence)
# and create some schedules without time entries (to show missed schedules)

# Get some completed time entries to match with schedules
completed_entries = TimeEntry.completed.limit(40)

completed_entries.each do |entry|
  # Create a schedule that matches this time entry
  schedule = Schedule.create!(
    user: entry.user,
    site: entry.site,
    scheduled_date: entry.clocked_in_at.to_date,
    start_time: entry.clocked_in_at.strftime('%H:%M'),
    end_time: entry.clocked_out_at.strftime('%H:%M'),
    status: 'completed',
    created_by: [admin1, admin2, manager1, manager2, manager3].sample,
    notes: 'Planification régulière'
  )
  created_schedules << schedule
  schedules_count += 1
end

puts "  ✓ Created #{schedules_count} completed schedules (matching time entries)"

# Create missed schedules (schedules without corresponding time entries from past)
(1..15).each do |i|
  agent = all_agents.sample
  site = created_sites.sample
  days_ago = rand(1..30)
  scheduled_date = days_ago.days.ago.to_date
  
  # Skip if this agent already has a time entry on this date for this site
  next if TimeEntry.exists?(
    user: agent,
    site: site,
    clocked_in_at: scheduled_date.beginning_of_day..scheduled_date.end_of_day
  )
  
  start_hour = rand(7..9)
  end_hour = start_hour + rand(7..9)
  
  schedule = Schedule.create!(
    user: agent,
    site: site,
    scheduled_date: scheduled_date,
    start_time: "#{start_hour}:00",
    end_time: "#{end_hour}:00",
    status: 'missed',
    created_by: [admin1, admin2, manager1, manager2, manager3].sample,
    notes: 'Agent absent sans notification'
  )
  created_schedules << schedule
  schedules_count += 1
end

puts "  ✓ Created 15 missed schedules (no corresponding time entries)"

# Create upcoming schedules (for future dates)
(1..25).each do |i|
  agent = all_agents.sample
  site = created_sites.sample
  days_ahead = rand(1..14)
  scheduled_date = days_ahead.days.from_now.to_date
  
  # Skip if already scheduled
  next if Schedule.exists?(
    user: agent,
    scheduled_date: scheduled_date
  )
  
  start_hour = rand(7..9)
  end_hour = start_hour + rand(7..9)
  
  schedule = Schedule.create!(
    user: agent,
    site: site,
    scheduled_date: scheduled_date,
    start_time: "#{start_hour}:00",
    end_time: "#{end_hour}:00",
    status: 'scheduled',
    created_by: [admin1, admin2, manager1, manager2, manager3].sample,
    notes: ['Planification hebdomadaire', 'Affectation régulière', 'Remplacement temporaire', nil].sample
  )
  created_schedules << schedule
  schedules_count += 1
end

puts "  ✓ Created 25 upcoming schedules"

# Create some schedules with replacements (5 schedules)
replacement_count = 0
attempts = 0
while replacement_count < 5 && attempts < 20
  attempts += 1
  original_agent = all_agents.sample
  replacement_agent = (all_agents - [original_agent]).sample
  site = created_sites.sample
  days_ahead = rand(1..7)
  scheduled_date = days_ahead.days.from_now.to_date
  
  # Skip if this agent already has a schedule on this date
  next if Schedule.exists?(user: original_agent, scheduled_date: scheduled_date)
  
  start_hour = rand(7..9)
  end_hour = start_hour + rand(7..9)
  
  schedule = Schedule.create!(
    user: original_agent,
    site: site,
    scheduled_date: scheduled_date,
    start_time: "#{start_hour}:00",
    end_time: "#{end_hour}:00",
    status: 'scheduled',
    created_by: [manager1, manager2, manager3].sample,
    replaced_by: replacement_agent,
    replacement_reason: ['Congé maladie', 'Formation', 'Urgence familiale', 'Congé planifié'].sample,
    notes: "Remplacé par #{replacement_agent.full_name}"
  )
  created_schedules << schedule
  schedules_count += 1
  replacement_count += 1
end

puts "  ✓ Created 5 schedules with replacements"

# Create a few cancelled schedules
(1..5).each do |i|
  agent = all_agents.sample
  site = created_sites.sample
  days_ago = rand(1..10)
  scheduled_date = days_ago.days.ago.to_date
  
  start_hour = rand(7..9)
  end_hour = start_hour + rand(7..9)
  
  schedule = Schedule.create!(
    user: agent,
    site: site,
    scheduled_date: scheduled_date,
    start_time: "#{start_hour}:00",
    end_time: "#{end_hour}:00",
    status: 'cancelled',
    created_by: [admin1, admin2].sample,
    notes: ['Maintenance site', 'Annulation client', 'Réorganisation planning'].sample
  )
  created_schedules << schedule
  schedules_count += 1
end

puts "  ✓ Created 5 cancelled schedules"

puts "\n✅ Seed completed successfully!"
puts "\n📊 Summary:"
puts "  - Admins: #{User.admins.count}"
puts "  - Managers: #{User.managers.count}"
puts "  - Agents (active): #{User.agents.active.count}"
puts "  - Agents (inactive): #{User.agents.where(active: false).count}"
puts "  - Total users: #{User.count}"
puts "  - Sites: #{Site.count}"
puts "  - Time Entries: #{TimeEntry.count}"
puts "    * Completed: #{TimeEntry.completed.count}"
puts "    * Active: #{TimeEntry.active.count}"
puts "    * Anomalies: #{TimeEntry.anomalies.count}"
puts "  - Schedules: #{Schedule.count}"
puts "    * Scheduled: #{Schedule.scheduled.count}"
puts "    * Completed: #{Schedule.completed.count}"
puts "    * Missed: #{Schedule.missed.count}"
puts "    * Cancelled: #{Schedule.cancelled.count}"

puts "\n🔐 Default credentials for testing:"
puts "  Admin: admin@madyproclean.fr / password123"
puts "  Manager: manager1@madyproclean.fr / password123"
puts "  Agent: agent1@madyproclean.fr / password123"
