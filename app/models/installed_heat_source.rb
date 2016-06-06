class InstalledHeatSource
  include Virtus.model

  attribute :key, String
  attribute :name, String
  attribute :units, Float
  attribute :heat_production, Float
  attribute :heat_capacity, Float
  attribute :total_initial_investment, Float
  attribute :technical_lifetime, Float
  attribute :om_costs_per_year, Float
  attribute :marginal_costs, Float
  attribute :profile, Integer
  attribute :stakeholder, String
  attribute :distance, Float
  attribute :dispatchable, Boolean
  attribute :priority, Integer
end
