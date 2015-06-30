module MarketModelsHelper
  def stakeholder_options(options = {})
    options_for_select(Stakeholder.all.map(&:name), options)
  end

  def tariff_options(options = {})
    options_for_select(MarketModel::BASES, options)
  end

  def financial_profile_options(options = {})
    options_for_select(FinancialProfile.all.map(&:key), options)
  end
end
