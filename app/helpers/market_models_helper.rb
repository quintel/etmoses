module MarketModelsHelper
  def stakeholder_options(options = {})
    stakeholders = Stakeholder.tree_sort.map do |stakeholder|
      name = "#{ "- " * (stakeholder.path.length - 1) }#{ stakeholder.name }"

      [ name, stakeholder.name, { data: { parent_id: stakeholder.parent_id }} ]
    end

    options_for_select(stakeholders, options)
  end

  def foundation_options(options = {})
    values = MarketModel::FOUNDATIONS.map do |key|
      [t("tariff.measure.#{ key.downcase }"), key]
    end.sort_by(&:first)

    options_for_select(values, options)
  end

  def measure_options(options = {})
    options_for_select(MarketModel::MEASURES, options)
  end

  def financial_profile_options(options = {})
    options_for_select(PriceCurve.all.map(&:key), options)
  end

  def format_interaction_foundation(interaction)
    t("tariff.measure.#{ interaction['foundation'].downcase }")
  end

  def format_interaction_applied_stakeholder(interaction)
    interaction['applied_stakeholder'] || interaction['stakeholder_from']
  end

  def format_interaction_tariff(interaction)
    type = t("tariff.type.#{ interaction['tariff_type'] }")

    tariff =
      if interaction['tariff_type'] == 'merit'
        '&ndash;'.html_safe
      else
        interaction['tariff']
      end

    [ content_tag(:span, type, class: 'tariff_type label'),
      content_tag(:span, tariff, class: 'tariff')
    ].join(' ').html_safe
  end
end
