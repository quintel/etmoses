module Finance
  class BusinessCaseComparator
    COMPARE_KEYS = %i(incoming outgoing freeform total)

    def initialize(business_case, other_business_case)
      raise ArgumentError unless (business_case && other_business_case)

      @business_case       = BusinessCaseSummary.new(business_case).summarize
      @other_business_case = BusinessCaseSummary.new(other_business_case).summarize
    end

    def compare
      @business_case.zip(@other_business_case).map do |pair|
        COMPARE_KEYS.map do |key|
          pair.last && pair.last[key] || 0
        end
      end
    end
  end
end
