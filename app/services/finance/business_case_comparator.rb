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
        ( @business_case.detect{|t| t[:stakeholder] == stakeholder } || { stakeholder: stakeholder }).merge(
          compare: @other_business_case.detect{|t| t[:stakeholder] == stakeholder })
      end
    end

    private

    def unison
      (@business_case + @other_business_case).map{|t| t[:stakeholder] }.uniq.sort
    end
  end
end
