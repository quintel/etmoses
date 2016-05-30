class GasAssetListDecorator
  def initialize(gas_asset_list)
    @gas_asset_list = gas_asset_list
  end

  def decorate
    @gas_asset_list.asset_list.map do |part|
      entity = StaticData::DATA_SOURCES[part['part']].where(type: part['type'])

      InstalledGasAsset.new(part.merge(entity.first.attributes))
    end
  end
end
