class CreateTimeEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :time_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :site, null: false, foreign_key: true
      t.datetime :clocked_in_at, null: false
      t.datetime :clocked_out_at
      t.integer :duration_minutes
      t.string :status, default: 'active', null: false
      t.string :ip_address_in
      t.string :ip_address_out
      t.string :user_agent_in
      t.string :user_agent_out
      t.text :notes
      t.boolean :manually_corrected, default: false, null: false
      t.references :corrected_by, foreign_key: { to_table: :users }
      t.datetime :corrected_at

      t.timestamps
    end

    add_index :time_entries, :clocked_in_at
    add_index :time_entries, :clocked_out_at
    add_index :time_entries, :status
    add_index :time_entries, :manually_corrected
    add_index :time_entries, [:user_id, :clocked_in_at]
    add_index :time_entries, [:site_id, :clocked_in_at]
  end
end
