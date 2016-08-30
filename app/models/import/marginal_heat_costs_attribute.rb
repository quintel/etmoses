class Import
  MarginalHeatCostsAttribute =
    Attribute.new('marginal_heat_costs') do |value, *|
      value / 1000 # EUR/MWh to EUR/kWh
    end
end
