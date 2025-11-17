class RemoveTypeSpecificColumnsFromReports < ActiveRecord::Migration[8.0]
  def change
    # Remove common metrics (will be calculated on demand)
    remove_column :reports, :total_hours, :decimal
    remove_column :reports, :total_agents, :integer
    remove_column :reports, :total_sites, :integer
    
    # Remove HR report specific fields
    remove_column :reports, :total_absences, :integer
    remove_column :reports, :absence_rate, :decimal
    remove_column :reports, :coverage_rate, :decimal
    
    # Remove Anomaly report specific fields
    remove_column :reports, :total_anomalies, :integer
    remove_column :reports, :resolved_anomalies, :integer
    remove_column :reports, :unresolved_anomalies, :integer
    
    # Remove Scheduling report specific fields
    remove_column :reports, :total_schedules, :integer
    remove_column :reports, :scheduled_count, :integer
    remove_column :reports, :completed_count, :integer
    remove_column :reports, :missed_count, :integer
    
    # Remove Site-specific report fields
    remove_column :reports, :site_name, :string
    remove_column :reports, :site_code, :string
  end
end
