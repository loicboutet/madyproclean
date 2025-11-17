class CreateAbsences < ActiveRecord::Migration[8.0]
  def change
    create_table :absences do |t|
      t.references :user, null: false, foreign_key: true
      t.string :absence_type, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, null: false, default: 'pending'
      t.text :reason
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    
    add_index :absences, :absence_type
    add_index :absences, :status
    add_index :absences, [:start_date, :end_date]
    add_index :absences, :created_at
  end
end
