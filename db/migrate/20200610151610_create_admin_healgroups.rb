class CreateAdminHealgroups < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_healgroups do |t|
      t.string :name, null: false, index: { unique: true }
      t.date :start_date, :default => Date.current, null: false

      t.timestamps
    end
  end
end
