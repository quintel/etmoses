class RenameTemperatureProfileIdToBehaviorProfileId < ActiveRecord::Migration
  def change
    rename_column :testing_grounds, :temperature_profile_id, :behavior_profile_id
  end
end
