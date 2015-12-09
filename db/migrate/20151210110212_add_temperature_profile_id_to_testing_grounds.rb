class AddTemperatureProfileIdToTestingGrounds < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :temperature_profile_id, :integer, after: :market_model_id
  end
end
