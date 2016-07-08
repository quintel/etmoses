module BusinessCaseCosts
  def total_yearly_costs
    (depreciation_costs     +
     om_costs_per_year.to_f +
     yearly_variable_om_costs) * units
  end

  def depreciation_costs
    (initial_investment.to_f / (technical_lifetime || 1))
  end

  def yearly_variable_om_costs
    0
  end
end
