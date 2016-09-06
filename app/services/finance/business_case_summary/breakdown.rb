module Finance
  class BusinessCaseSummary
    module Breakdown
      def label_for_stakeholder(current_stakeholder)
        if stakeholder == current_stakeholder
          I18n.t("business_case.depreciation_costs")
        else
          current_stakeholder.humanize
        end
      end

      def breakdown(costs)
        result = costs.each_with_index.map do |value, index|
          [label_for_stakeholder(stakeholders[index]), value] if value
        end

        Hash[result.compact]
      end
    end
  end
end
