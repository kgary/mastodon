class ChangeDefaultLockedInAccounts < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:accounts, :locked, true)
  end
end
