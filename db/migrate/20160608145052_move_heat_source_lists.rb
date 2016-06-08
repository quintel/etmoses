class MoveHeatSourceLists < ActiveRecord::Migration
  def change
    HeatSourceList.all.map do |heat_source_list|
      asset_list = AssetList.new
      asset_list.testing_ground_id = heat_source_list.testing_ground_id
      asset_list.asset_list = heat_source_list.source_list
      asset_list.type = "HeatSourceList"
      asset_list.save
    end
  end
end
