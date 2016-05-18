class InstalledHeatSource
  include Virtus.model

  attribute :key, String
  attribute :name, String
  attribute :units, Float
  attribute :heat_production, Float, default: 0.0
  attribute :heat_capacity, Float, default: 0.0
  attribute :total_initial_investment, Float, default: 0.0
  attribute :technical_lifetime, Float, default: 1.0
  attribute :om_costs_per_year, Float, default: 0.0
  attribute :marginal_costs, Float
  attribute :profile, Integer
  attribute :stakeholder, String
  attribute :distance, Float
  attribute :dispatchable, Boolean
  attribute :priority, Integer

  def total_investment_costs
    (initial_investment / technical_lifetime) + om_costs
  end

  private

  def initial_investment
    total_initial_investment.to_f * costs_multiplier
  end

  def om_costs
    om_costs_per_year * costs_multiplier
  end

  def costs_multiplier
    (dispatchable ? heat_capacity * units : heat_production)
  end
end
