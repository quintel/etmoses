class Import
  CentralHeatNetworkMustRunHeatProductionAttribute = Attribute.new(
    'heat_production',
    'etmoses_must_run_heat_for_households_from_central_heat_network'
  ) do |value, _|
    (value * (1.0 / 3.6)).round # MJ to kWh
  end
end
