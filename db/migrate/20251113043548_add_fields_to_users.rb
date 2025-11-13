class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string, default: 'agent', null: false
    add_column :users, :first_name, :string, null: false
    add_column :users, :last_name, :string, null: false
    add_column :users, :employee_number, :string
    add_column :users, :active, :boolean, default: true, null: false
    add_column :users, :phone_number, :string
    add_column :users, :manager_id, :integer
    
    # Add indexes for performance
    add_index :users, :role
    add_index :users, :active
    add_index :users, :manager_id
    add_index :users, :employee_number, unique: true, where: "employee_number IS NOT NULL"
    
    # Add foreign key constraint
    add_foreign_key :users, :users, column: :manager_id
  end
end
