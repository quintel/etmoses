class MoveGasAssetLists < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.select(
      'SELECT * from gas_asset_lists'
    ).each do |row|
      GasAssetList.create!(row.except('id'))
    end
  end
end
