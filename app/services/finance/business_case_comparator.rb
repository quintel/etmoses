module Finance
  class BusinessCaseComparator
    COMPARE_KEYS = %i(incoming outgoing freeform total)

    def initialize(business_case, other_business_case)
      raise ArgumentError unless (business_case && other_business_case)

      @business_case       = BusinessCaseSummary.new(business_case).summarize
      @other_business_case = BusinessCaseSummary.new(other_business_case).summarize
    end

    def compare
      unison.map do |stakeholder|
        business_case_stakeholder = find_stakeholder(@business_case, stakeholder)
        other_business_case_stakeholder = find_stakeholder(@other_business_case, stakeholder)

        (business_case_stakeholder || { stakeholder: stakeholder })
          .merge(compare: other_business_case_stakeholder)
      end
    end

    private

    def find_stakeholder(business_case, stakeholder)
      business_case.detect do |t|
        t[:stakeholder] == stakeholder
      end
    end

    def unison
      (@business_case + @other_business_case).map{|t| t[:stakeholder] }.uniq.sort
    end
  end
end
