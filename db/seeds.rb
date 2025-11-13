# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting seed process..."

# Clear existing data (in development only)
if Rails.env.development?
  puts "🧹 Cleaning existing data..."
  # Disable foreign key checks temporarily for SQLite
  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")
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

puts "\n✅ Seed completed successfully!"
puts "\n📊 Summary:"
puts "  - Admins: #{User.admins.count}"
puts "  - Managers: #{User.managers.count}"
puts "  - Agents (active): #{User.agents.active.count}"
puts "  - Agents (inactive): #{User.agents.where(active: false).count}"
puts "  - Total users: #{User.count}"

puts "\n🔐 Default credentials for testing:"
puts "  Admin: admin@madyproclean.fr / password123"
puts "  Manager: manager1@madyproclean.fr / password123"
puts "  Agent: agent1@madyproclean.fr / password123"
