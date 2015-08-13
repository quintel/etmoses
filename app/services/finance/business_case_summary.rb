module Finance
  class BusinessCaseSummary
    def initialize(business_case)
      @business_case = business_case
    end

    def summarize
      financials_without_freeform.each_with_index.map do |financial_rule, index|
        incoming = financial_rule.values.flatten.compact.reduce(:+)
        outgoing = transposed_financials[index].compact.reduce(:+)
        freeform = (freeform_row[index] || 0)

        {
          stakeholder: financial_rule.keys.first,
          incoming: incoming,
          outgoing: outgoing,
          freeform: freeform,
          total: (incoming || 0) + (outgoing || 0) + freeform
        }
      end
    end

    private

    def financials
      @financials ||= @business_case.financials
    end

    def freeform_row
      (financials.detect(&freeform_proc) || {}).values.flatten
    end

    def financials_without_freeform
      financials.reject(&freeform_proc)
    end

    def freeform_proc
      Proc.new{|t| t.keys.first == "freeform" }
    end

    def transposed_financials
      financials_without_freeform.map{ |f| f.values.flatten }.transpose
    end
  end
end
