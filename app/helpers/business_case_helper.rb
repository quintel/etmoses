module BusinessCaseHelper
  def finance_table_freeform_row(business_case)
    business_case.freeform.values.flatten
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
end
