class InstalledGasAsset
  include Virtus.model

  attribute :pressure_level_index, Integer
  attribute :part, String
  attribute :type, String
  attribute :amount, Integer
  attribute :stakeholder, String
  attribute :building_year, Integer
  attribute :lifetime, Integer
  attribute :investment_cost, Float

  def decommissioning_year
    building_year + lifetime
  end

  def net_present_value_at(year)
    if year.between?(building_year, decommissioning_year)
      ((lifetime - (year.to_f - building_year.to_f)) / lifetime) * investment_cost
    else
      0
    end
  end

  def total_investment_costs
    investment_cost * amount
  end
end
