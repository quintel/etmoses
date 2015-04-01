class RemoveCapacityAttributesFromLoadCurve < ActiveRecord::Migration
  def up
    remove_column :load_profiles, :capacity_group
    remove_column :load_profiles, :min_capacity
  end

  def down
    add_column :load_profiles, :capacity_group, :string
    add_column :load_profiles, :min_capacity,   :float
  end
end
