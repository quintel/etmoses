class InstalledHeatAssetPipe < InstalledHeatAsset
  attribute :distance, Float, default: 1.0
  attribute :investment_costs_per_km, Float
  attribute :heat_source, String
  attribute :om_costs_per_year_per_km, Float

  def total_yearly_costs
    ((investment_costs_per_km * distance) / technical_lifetime) +
    (om_costs_per_year_per_km * distance)
  end
end
