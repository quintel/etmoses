module MarketModelsHelper
  def stakeholder_options(options = {})
    options_for_select(Stakeholder.all, options)
  end

  def foundation_options(options = {})
    options_for_select(MarketModel::FOUNDATIONS, options)
  end

  def measure_options(options = {})
    options_for_select(MarketModel::MEASURES, options)
  end

  def financial_profile_options(options = {})
    options_for_select(PriceCurve.all.map(&:key), options)
  end
end
