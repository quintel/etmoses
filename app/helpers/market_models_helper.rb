module MarketModelsHelper
  def stakeholder_options(options = {})
    options_for_select(Stakeholder.all.map(&:name), options)
  end

  def tariff_options(options = {})
    options_for_select(MarketModel::BASES, options)
  end
end
