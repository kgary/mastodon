class AddHealGroupNameAndInviteEndToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :heal_group_name, :string, :default => "Global"
    add_column :users, :invite_end, :string, :default => "No link"
  end
end
