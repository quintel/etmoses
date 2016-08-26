class HeatSourceList < AssetList
  def sorted_asset_list
    asset_list.sort_by do |part|
      part[:priority].to_i || -1
    end
  end
end
