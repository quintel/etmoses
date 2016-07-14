class InstalledHeatAssetLocation < InstalledHeatAsset
  attribute :investment_costs, Float
  attribute :om_costs_per_year, Float
  attribute :connection_distribution, Float
  # Please remove the default; connection_distribution * total heat connections
  attribute :number_of_units, Float, default: 0.0

  def total_yearly_costs
    ((investment_costs * number_of_units) / technical_lifetime) +
    (om_costs_per_year * number_of_units)
  end
end
