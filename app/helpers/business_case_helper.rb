module BusinessCaseHelper
  def freeform_value(business_case, stakeholder)
    business_case.freeform['freeform'][stakeholder] || 0.0
  end

  def finance_table_rows(business_case)
    if business_case.financials
      business_case.financials.reject{|t| t['freeform']}
    else
      []
    end
  end

  def valid_financial_row?(financial_row)
    if financial_row[:compare]
      valid_financial_statement?(financial_row[:compare])
    else
      valid_financial_statement?(financial_row)
    end
  end

  def valid_financial_statement?(setting)
    setting[:incoming] || setting[:outgoing]
  end

  def clear_business_case?(testing_ground)
    testing_ground.cache_updated_at > testing_ground.business_case.updated_at
  end

  def content_for_breakdown(breakdown)
    return unless breakdown

    breakdown_spans = breakdown.each_pair.map do |stakeholder, value|
                        stakeholder_span = content_tag(:span,
                          "#{ stakeholder }: ", "class" => "stakeholder")

                        stakeholder_span + number_to_currency(value)
                      end

    breakdown_spans.join("<br/>")
  end

  def breakdown_data(breakdown)
    {
      toggle:  'popover',
      trigger: 'hover',
      html:    'true',
      content: content_for_breakdown(breakdown)
    }
  end
end
