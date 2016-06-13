class Import
  CentralHeatNetworkMustRunHeatProductionAttribute = Attribute.new(
    'heat_production',
    'etmoses_must_run_heat_for_households_from_central_heat_network'
  ) do |value, _|
    value.round(5)
  end
end
