class Import
  CentralHeatNetworkDispatchableCapacityAttribute = Attribute.new(
    'heat_capacity',
    'etmoses_dispatchable_capacity_for_households_from_central_heat_network'
  ) do |value, _|
    value.round(5)
  end
end
