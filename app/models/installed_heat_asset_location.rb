class InstalledHeatAssetLocation < InstalledHeatAsset
  attribute :investment_costs, Float
  attribute :om_costs_per_year, Float
  attribute :connection_distribution, Float
  attribute :number_of_units, Float # connection_distribution * total heat connections

  def depreciation_costs
    ((investment_costs * number_of_units) / technical_lifetime) +
    (om_costs_per_year * number_of_units)
  end
end
