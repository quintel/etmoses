module BusinessCaseHelper
  def finance_table_freeform_row(business_case)
    if business_case.financials
      (business_case.financials.detect{|t| t['freeform'] } ||
       BusinessCase::FREEFORM_ROW).values.flatten
    else
      BusinessCase::FREEFORM_ROW.values.flatten
    end
  end

  def finance_table_rows(business_case)
    if business_case.financials
      business_case.financials.reject{|t| t['freeform']}
    else
      []
    end
  end
end
