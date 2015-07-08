class RemoveStakeholders < ActiveRecord::Migration
  def change
    drop_table :stakeholders
  end
end
