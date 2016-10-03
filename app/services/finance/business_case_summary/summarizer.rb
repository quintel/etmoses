module Finance
  class BusinessCaseSummary
    module Summarizer
      include Breakdown

      def summarize_rule(financial_rule, index)
        @financial_rule = financial_rule
        @index          = index
        @incoming       = incoming_all.compact.inject(:+)
        @outgoing       = outgoing_all.compact.inject(:+)

        {
          stakeholder:        stakeholder,
          incoming:           @incoming,
          incoming_breakdown: breakdown(incoming_from_rule, skip),
          outgoing:           @outgoing,
          outgoing_breakdown: breakdown(outgoing_all),
          freeform:           freeform,
          total:              total
        }
      end

      private

      def stakeholder
        @financial_rule.keys.first
      end

      def incoming_from_rule
        @financial_rule.values.flatten
      end

      def outgoing_all
        transposed_financials[@index]
      end

      def incoming_all
        values = incoming_from_rule
        values.delete_at(skip)
        values
      end

      def skip
        stakeholders.index(stakeholder)
      end

      def stakeholders
        @stakeholders ||= @business_case.financials.map(&:keys).flatten
      end

      def freeform
        freeform_row[stakeholder] && -freeform_row[stakeholder]
      end

      def total
        (@incoming || 0) - (@outgoing || 0) + (freeform || 0)
      end
    end
  end
end
