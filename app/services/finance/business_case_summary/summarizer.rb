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
        values.compact.sum
      end

      def skip
        Stakeholder.all.index(stakeholder)
      end

      def outgoing
        transposed_financials[@index].compact.sum
      end

      def freeform
        freeform_row[@index] || 0
      end

      def total
        incoming - outgoing + freeform
      end
    end
  end
end
