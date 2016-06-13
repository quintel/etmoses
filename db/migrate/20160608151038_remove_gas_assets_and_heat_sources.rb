class RemoveGasAssetsAndHeatSources < ActiveRecord::Migration
  def change
    drop_table :heat_source_lists
    drop_table :gas_asset_lists
  end
end
