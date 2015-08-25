module BusinessCaseHelper
  def finance_table_freeform_row(business_case)
    (business_case.financials.detect{|t| t['freeform'] } ||
     BusinessCase::FREEFORM_ROW).values.flatten
  end

  def finance_table_rows(business_case)
    business_case.financials.reject{|t| t['freeform']}
  end
end
