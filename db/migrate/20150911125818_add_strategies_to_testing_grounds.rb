class AddStrategiesToTestingGrounds < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :strategies, :text, after: :parent_scenario_id
  end
end
