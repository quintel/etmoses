class AddMarketModelIdToTestingGround < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :market_model_id, :integer, after: :topology_id
  end
end
