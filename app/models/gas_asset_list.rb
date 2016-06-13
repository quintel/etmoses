class GasAssetList < AssetList
  PRESSURE_LEVELS = [0.125, 4, 8, 40]

  def sorted_asset_list
    asset_list.sort_by do |part|
      part[:pressure_level_index].to_i || -1
    end
  end
end
