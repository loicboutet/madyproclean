class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.string :title, null: false
      t.string :report_type, null: false
      t.date :period_start
      t.date :period_end
      t.datetime :generated_at
      t.integer :generated_by_id
      t.string :status, default: 'pending', null: false
      t.text :description
      t.decimal :total_hours, precision: 10, scale: 2
      t.integer :total_agents
      t.integer :total_sites
      t.text :filters_applied
      t.string :file_format
      t.string :file_size
      
      # HR report specific fields
      t.integer :total_absences
      t.decimal :absence_rate, precision: 5, scale: 2
      t.decimal :coverage_rate, precision: 5, scale: 2
      
      # Anomaly report specific fields
      t.integer :total_anomalies
      t.integer :resolved_anomalies
      t.integer :unresolved_anomalies
      
      # Scheduling report specific fields
      t.integer :total_schedules
      t.integer :scheduled_count
      t.integer :completed_count
      t.integer :missed_count
      
      # Site-specific report fields
      t.string :site_name
      t.string :site_code

      t.timestamps
    end
    
    add_index :reports, :report_type
    add_index :reports, :status
    add_index :reports, :generated_at
    add_index :reports, :generated_by_id
    add_index :reports, [:period_start, :period_end]
  end
end
