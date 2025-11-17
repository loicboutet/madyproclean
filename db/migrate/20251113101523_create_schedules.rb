class CreateSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :schedules do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :site, null: false, foreign_key: true, index: true
      t.date :scheduled_date, null: false, index: true
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.text :notes
      t.string :status, default: 'scheduled', null: false, index: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :replaced_by, null: true, foreign_key: { to_table: :users }
      t.text :replacement_reason

      t.timestamps
    end

    # Composite indexes for common queries
    add_index :schedules, [:user_id, :scheduled_date], name: 'index_schedules_on_user_id_and_scheduled_date'
    add_index :schedules, [:site_id, :scheduled_date], name: 'index_schedules_on_site_id_and_scheduled_date'
  end
end
