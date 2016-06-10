class InstalledHeatAssetPipe < InstalledHeatAsset
  attribute :distance, Float
  attribute :investment_costs_per_km, Float
  attribute :heat_source, String
  attribute :om_costs_per_year_per_km, Float

  def total_investment_costs
    0
  end
end
