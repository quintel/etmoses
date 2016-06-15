class Import
  module HeatSourceBuilder
    NumberOfUnitsAttribute     = Attribute.new('number_of_units')
    TechnicalLifetimeAttribute = Attribute.new('technical_lifetime')
    MarginalHeatCostsAttribute = Attribute.new('marginal_heat_costs')

    def self.build(key, data)
      tech = Technology.by_key(key)

      tech.defaults.merge(
        'key'                      => key,
        'units'                    => NumberOfUnitsAttribute.call(data),
        'heat_capacity'            => HeatCapacityAttribute.call(data),
        'heat_production'          => HeatProductionAttribute.call(data),
        'total_initial_investment' => TotalInitialInvestmentAttribute.call(data),
        'technical_lifetime'       => TechnicalLifetimeAttribute.call(data),
        'om_costs_per_year'        => FixedOmCostsPerYearPerMwAttribute.call(data),
        'marginal_heat_costs'      => MarginalHeatCostsAttribute.call(data).round(1)
      )
    end
  end
end
