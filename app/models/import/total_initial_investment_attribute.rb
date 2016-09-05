class Import
  TotalInitialInvestmentAttribute = Attribute.new(
    'total_initial_investment', 'total_initial_investment_per_mw'
  ) do |value, _|
    value / 1000 # EUR/MW to EUR/kW
  end
end
