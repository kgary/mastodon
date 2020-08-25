class AddFutureselfAndGoalsToStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :statuses, :futureself, :boolean
    add_column :statuses, :goal, :boolean
  end
end
