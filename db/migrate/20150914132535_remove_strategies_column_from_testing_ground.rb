class RemoveStrategiesColumnFromTestingGround < ActiveRecord::Migration
  def change
    remove_column :testing_grounds, :strategies
  end
end
