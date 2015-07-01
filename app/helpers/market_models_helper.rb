module MarketModelsHelper
  def stakeholder_options(options = {})
    options_for_select(Stakeholder.all.map(&:name), options)
  end

  def foundation_options(options = {})
    options_for_select(MarketModel::FOUNDATIONS, options)
  end

  def financial_profile_options(options = {})
    options_for_select(FinancialProfile.all.map(&:key), options)
  end
end
