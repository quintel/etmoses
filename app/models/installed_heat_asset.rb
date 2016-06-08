class InstalledHeatAsset
  include Virtus.model

  attribute :type, String
  attribute :scope, String
  attribute :distance, Float
  attribute :total_initial_investment, Float
  attribute :om_costs_per_year, Float
  attribute :technical_lifetime, Float
  attribute :costs_per_year, Float
  attribute :stakeholder, String

  def primary?
    scope == "primary"
  end

  def secondary?
    scope == "secondary"
  end
end
