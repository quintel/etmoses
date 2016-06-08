class HeatAssetListDecorator
  def initialize(heat_asset_list)
    @heat_asset_list = heat_asset_list
  end

  def decorate
    @heat_asset_list.asset_list.map do |part|
      InstalledHeatAsset.new(part)
    end
  end
end
