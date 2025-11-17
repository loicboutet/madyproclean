# Ruby script to distribute all records to 6 users (1 admin, 2 managers, 3 agents)
# and remove all other users from the database
#
# Usage: Run this in Rails console:
#   load 'lib/tasks/distribute_records.rb'

puts "=" * 80
puts "RECORD DISTRIBUTION AND USER CLEANUP SCRIPT"
puts "=" * 80
puts ""

ActiveRecord::Base.transaction do
  begin
    # Step 1: Identify the 6 users to keep
    puts "Step 1: Identifying users to keep..."
    
    admin = User.admins.order(:id).first
    managers = User.managers.order(:id).limit(2).to_a
    agents = User.agents.order(:id).limit(3).to_a
    
    # Validate we have the required users
    raise "No admin found!" unless admin
    raise "Need at least 2 managers, found #{managers.count}" if managers.count < 2
    raise "Need at least 3 agents, found #{agents.count}" if agents.count < 3
    
    keep_user_ids = [admin.id] + managers.map(&:id) + agents.map(&:id)
    all_keepers = [admin] + managers + agents
    
    puts "✓ Admin: #{admin.full_name} (ID: #{admin.id}, Email: #{admin.email})"
    managers.each_with_index do |manager, i|
      puts "✓ Manager #{i+1}: #{manager.full_name} (ID: #{manager.id}, Email: #{manager.email})"
    end
    agents.each_with_index do |agent, i|
      puts "✓ Agent #{i+1}: #{agent.full_name} (ID: #{agent.id}, Email: #{agent.email})"
    end
    puts ""
    
    # Step 2: Assign agents to managers
    puts "Step 2: Assigning agents to managers..."
    agents.each_with_index do |agent, i|
      manager = managers[i % managers.count]
      agent.update!(manager_id: manager.id)
      puts "✓ #{agent.full_name} -> managed by #{manager.full_name}"
    end
    puts ""
    
    # Step 3: Redistribute Time Entries
    puts "Step 3: Redistributing Time Entries..."
    time_entries = TimeEntry.all.to_a
    time_entries.each_with_index do |entry, i|
      new_owner = all_keepers[i % all_keepers.count]
      corrector = all_keepers.sample
      
      # Mark as manually corrected to bypass validation for multiple active entries
      entry.update!(
        user_id: new_owner.id,
        manually_corrected: true,
        corrected_by_id: corrector.id,
        corrected_at: Time.current
      )
    end
    puts "✓ Redistributed #{time_entries.count} time entries"
    puts ""
    
    # Step 4: Redistribute Schedules
    puts "Step 4: Redistributing Schedules..."
    schedules = Schedule.all.to_a
    schedules.each_with_index do |schedule, i|
      assigned_agent = agents[i % agents.count]
      creator = [admin] + managers
      created_by = creator.sample
      replaced_by = schedule.replaced_by_id ? agents.sample : nil
      
      schedule.update!(
        user_id: assigned_agent.id,
        created_by_id: created_by.id,
        replaced_by_id: replaced_by&.id
      )
    end
    puts "✓ Redistributed #{schedules.count} schedules"
    puts ""
    
    # Step 5: Redistribute Absences
    puts "Step 5: Redistributing Absences..."
    absences = Absence.all.to_a
    absences.each_with_index do |absence, i|
      assigned_agent = agents[i % agents.count]
      creator = [admin] + managers
      created_by = creator.sample
      
      absence.update!(
        user_id: assigned_agent.id,
        created_by_id: created_by.id
      )
    end
    puts "✓ Redistributed #{absences.count} absences"
    puts ""
    
    # Step 6: Redistribute Anomaly Logs
    puts "Step 6: Redistributing Anomaly Logs..."
    anomalies = AnomalyLog.all.to_a
    anomalies.each_with_index do |anomaly, i|
      assigned_user = anomaly.user_id ? all_keepers[i % all_keepers.count] : nil
      resolver = anomaly.resolved_by_id ? all_keepers.sample : nil
      
      anomaly.update!(
        user_id: assigned_user&.id,
        resolved_by_id: resolver&.id
      )
    end
    puts "✓ Redistributed #{anomalies.count} anomaly logs"
    puts ""
    
    # Step 7: Redistribute Reports
    puts "Step 7: Redistributing Reports..."
    reports = Report.all.to_a
    managers_and_admin = [admin] + managers
    reports.each_with_index do |report, i|
      generator = report.generated_by_id ? managers_and_admin.sample : nil
      
      report.update!(generated_by_id: generator&.id)
    end
    puts "✓ Redistributed #{reports.count} reports"
    puts ""
    
    # Step 8: Clean up manager references and delete users
    puts "Step 8: Cleaning up manager references and deleting users..."
    users_to_delete = User.where.not(id: keep_user_ids)
    deleted_count = users_to_delete.count
    
    if deleted_count > 0
      puts "Users to be deleted:"
      users_to_delete.each do |user|
        puts "  - #{user.full_name} (#{user.role}, ID: #{user.id})"
      end
      
      # Nullify all manager_id references for users being deleted to avoid FK constraint
      users_to_delete.update_all(manager_id: nil)
      puts "✓ Nullified manager references for #{deleted_count} users"
      
      # Delete the users (their dependent records have already been reassigned)
      users_to_delete.delete_all
      puts "✓ Deleted #{deleted_count} users"
    else
      puts "✓ No additional users to delete"
    end
    puts ""
    
    # Step 9: Final verification
    puts "Step 9: Final verification..."
    remaining_users = User.count
    puts "✓ Total users remaining: #{remaining_users}"
    puts "  - Admins: #{User.admins.count}"
    puts "  - Managers: #{User.managers.count}"
    puts "  - Agents: #{User.agents.count}"
    puts ""
    
    # Summary
    puts "=" * 80
    puts "SUMMARY"
    puts "=" * 80
    puts "✓ Kept 6 users (1 admin, 2 managers, 3 agents)"
    puts "✓ Redistributed #{time_entries.count} time entries"
    puts "✓ Redistributed #{schedules.count} schedules"
    puts "✓ Redistributed #{absences.count} absences"
    puts "✓ Redistributed #{anomalies.count} anomaly logs"
    puts "✓ Redistributed #{reports.count} reports"
    puts "✓ Deleted #{deleted_count} users"
    puts ""
    puts "All operations completed successfully!"
    puts "=" * 80
    
  rescue => e
    puts ""
    puts "❌ ERROR: #{e.message}"
    puts e.backtrace.first(5).join("\n")
    puts ""
    puts "Rolling back all changes..."
    raise ActiveRecord::Rollback
  end
end

puts ""
puts "Script execution completed."
puts ""
