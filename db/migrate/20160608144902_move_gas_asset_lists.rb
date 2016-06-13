class MoveGasAssetLists < ActiveRecord::Migration
  def change
    GasAssetList.all.map do |gas_asset_list|
      asset_list = AssetList.new(gas_asset_list.attributes)
      asset_list.type = "GasAssetList"
      asset_list.save
    end
  end
end
