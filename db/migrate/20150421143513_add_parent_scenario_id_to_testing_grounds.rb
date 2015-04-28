class AddParentScenarioIdToTestingGrounds < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :parent_scenario_id, :integer
  end
end
