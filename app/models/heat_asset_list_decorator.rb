class HeatAssetListDecorator
  def initialize(heat_asset_list)
    @heat_asset_list = heat_asset_list
  end

  def decorate
    @heat_asset_list.asset_list.map do |part|
      case part[:scope]
      when 'primary'
        InstalledHeatAssetPipe.new(part)
      when 'secondary'
        InstalledHeatAssetLocation.new(part)
      else
        fail 'No such scope for Heat Asset'
      end
    end
  end
end
