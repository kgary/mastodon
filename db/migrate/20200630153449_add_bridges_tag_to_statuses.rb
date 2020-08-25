class AddBridgesTagToStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :statuses, :bridges_tag, :boolean
  end
end
