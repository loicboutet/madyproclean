class AddPeriodTypeToReports < ActiveRecord::Migration[8.0]
  def change
    add_column :reports, :period_type, :string, default: 'monthly'
    add_index :reports, :period_type
  end
end
