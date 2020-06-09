class CreateHealGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :heal_groups do |t|
      t.string :name, null: false, index: { unique: true }
      t.date :start_date, :default => Date.current

      t.timestamps
    end
  end
end
