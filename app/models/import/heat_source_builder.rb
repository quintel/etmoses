class Import
  module HeatSourceBuilder
    NumberOfUnitsAttribute     = Attribute.new('number_of_units')
    TechnicalLifetimeAttribute = Attribute.new('technical_lifetime')
    MarginalCostsAttribute     = Attribute.new('marginal_costs')

    def self.build(key, data)
      tech = Technology.by_key(key)

      tech.defaults.merge(
        'key'                      => key,
        'name'                     => I18n.t("heat_sources.#{ key }"),
        'units'                    => NumberOfUnitsAttribute.call(data),
        'heat_capacity'            => HeatCapacityAttribute.call(data),
        'heat_production'          => HeatProductionAttribute.call(data),
        'total_initial_investment' => TotalInitialInvestmentAttribute.call(data),
        'technical_lifetime'       => TechnicalLifetimeAttribute.call(data),
        'om_costs_per_year'        => FixedOmCostsPerYearPerMwAttribute.call(data),
        'marginal_costs'           => MarginalCostsAttribute.call(data)
      )
    end
  end
end
