class UpdateGasAssetLists < ActiveRecord::Migration
  def change
    translations = {
      investment_cost: :initial_investment,
      lifetime: :technical_lifetime,
      amount: :units
    }

    GasAssetList.all.each do |gas_asset|
      asset_list = gas_asset.asset_list.map do |asset_item|
        translations.each_pair do |old_key, new_key|
          asset_item[new_key] = asset_item[old_key]
          asset_item.delete(old_key)
        end

        asset_item
      end

      gas_asset.update_attribute(:asset_list, asset_list)
    end
  end
end
