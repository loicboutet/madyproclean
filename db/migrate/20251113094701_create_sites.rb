class CreateSites < ActiveRecord::Migration[8.0]
  def change
    create_table :sites do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :address
      t.text :description
      t.boolean :active, default: true, null: false
      t.string :qr_code_token, null: false

      t.timestamps
    end

    add_index :sites, :name
    add_index :sites, :code, unique: true
    add_index :sites, :qr_code_token, unique: true
    add_index :sites, :active
  end
end
