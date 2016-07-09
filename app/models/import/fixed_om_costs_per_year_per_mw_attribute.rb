class Import
  FixedOmCostsPerYearPerMwAttribute =
    Attribute.new(
      'om_costs_per_year',
      'fixed_operation_and_maintenance_costs_per_year_per_mw') do |value, _|
        (value / 1000).round(2) # EUR/MW to EUR/kW
      end
end

