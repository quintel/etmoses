class GasAssetListDecorator
  DEFAULT = {
    pressure_level_index:  0,
    part:                  'connectors',
    type:                  'blank',
    units:                 '1',
    stakeholder:           'system operator',
    building_year:         '1960',
    technical_lifetime:    0,
    initial_investment:    0
  }

  def initialize(gas_asset_list)
    @gas_asset_list = gas_asset_list
  end

  def decorate
    @gas_asset_list.sorted_asset_list.map do |part|
      entity = GasAssets::Base.type_for(part[:part]).where(type: part[:type])

      InstalledGasAsset.new(part.merge(entity.first.attributes)) if entity.first
    end.compact
  end
end
