class Import
  TotalInitialInvestmentAttribute = Attribute.new(
    'total_initial_investment', 'total_initial_investment_per_mw'
  ) do |value, _|
    # Unit = kEUR/MW
    (value / 1000).round(2)
  end
end
