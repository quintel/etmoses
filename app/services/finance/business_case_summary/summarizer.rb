module Finance
  class BusinessCaseSummary
    module Summarizer
      KEYS = %i(stakeholder incoming outgoing freeform total)

      def summarize_rule(financial_rule, index)
        @financial_rule = financial_rule
        @index = index

        Hash[KEYS.map do |key|
          [key, self.send(key)]
        end]
      end

      private

      def stakeholder
        @financial_rule.keys.first
      end

      def incoming
        values = @financial_rule.values.flatten
        values.delete_at(skip)
        values.compact.inject(:+)
      end

      def skip
        stakeholders.index(stakeholder)
      end

      def stakeholders
        @stakeholders ||= @business_case.financials.map(&:keys).flatten
      end

      def outgoing
        transposed_financials[@index].compact.inject(:+)
      end

      def freeform
        freeform_row[stakeholder] && -freeform_row[stakeholder]
      end

      def total
        (incoming || 0) - (outgoing || 0) + (freeform || 0)
      end
    end
  end
end
