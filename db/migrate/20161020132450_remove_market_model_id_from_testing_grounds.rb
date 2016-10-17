class RemoveMarketModelIdFromTestingGrounds < ActiveRecord::Migration
  def change
    remove_column :testing_grounds, :market_model_id
  end
end
