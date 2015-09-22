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

  def format_interaction_tariff(interaction)
    type = t("tariff.type.#{ interaction['tariff_type'] }")

    [ content_tag(:span, type, class: 'tariff_type label label-default'),
      content_tag(:span, interaction['tariff'], class: 'tariff')
    ].join(' ').html_safe
  end
end
