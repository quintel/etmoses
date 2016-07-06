class GasAssetListDecorator
  DEFAULT = {
    pressure_level_index:  0,
    part:                  'connectors',
    type:                  'blank',
    amount:                '1',
    stakeholder:           'system operator',
    building_year:         '1960',
    lifetime:              0,
    investment_cost:       0
  }

  def initialize(gas_asset_list)
    @gas_asset_list = gas_asset_list
  end

  def decorate
    @gas_asset_list.sorted_asset_list.map do |part|
      entity = GasAssets::Base.type_for(part[:part]).where(type: part[:type])

      InstalledGasAsset.new(part.merge(entity.first.attributes))
    end
  end
end
