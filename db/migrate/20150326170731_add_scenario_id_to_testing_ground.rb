class AddScenarioIdToTestingGround < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :scenario_id, :integer
  end
end
