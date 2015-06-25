module MarketModelsHelper
  def stakeholder_options
    options_for_select(Stakeholder.all.map(&:name))
  end

  def tariff_options
    options_for_select(MarketModel::BASES)
  end
end
