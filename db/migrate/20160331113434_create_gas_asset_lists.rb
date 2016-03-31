class CreateGasAssetLists < ActiveRecord::Migration
  def change
    create_table :gas_asset_lists do |t|
      t.belongs_to(:testing_ground)
      t.text :asset_list
      t.timestamps
    end
  end
end
