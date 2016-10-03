module Finance
  class BusinessCaseSummary
    module Breakdown
      def label_for_stakeholder(current_stakeholder)
        if stakeholder == current_stakeholder
          I18n.t("business_case.yearly_costs")
        else
          current_stakeholder.humanize
        end
      end

      def breakdown(costs, skip = nil)
        result = costs.each_with_index.map do |value, index|
          if value && skip != index
            [label_for_stakeholder(stakeholders[index]), value]
          end
        end

        Hash[result.compact]
      end
    end
  end
end
