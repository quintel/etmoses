class InstalledHeatAssetLocation < InstalledHeatAsset
  attribute :distance, Float
  attribute :investment_costs, Float
  attribute :source, String
  attribute :om_costs_per_year, Float

  def total_investment_costs
    0
  end
end
