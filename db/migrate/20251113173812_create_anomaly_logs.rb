class CreateAnomalyLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :anomaly_logs do |t|
      t.string :anomaly_type, null: false
      t.string :severity, default: 'medium', null: false
      t.references :user, foreign_key: true, index: true
      t.references :time_entry, foreign_key: true, index: true
      t.references :schedule, foreign_key: true, index: true
      t.text :description, null: false
      t.boolean :resolved, default: false, null: false
      t.references :resolved_by, foreign_key: { to_table: :users }, index: true
      t.datetime :resolved_at
      t.text :resolution_notes

      t.timestamps
    end

    add_index :anomaly_logs, :anomaly_type
    add_index :anomaly_logs, :severity
    add_index :anomaly_logs, :resolved
    add_index :anomaly_logs, :created_at
  end
end
