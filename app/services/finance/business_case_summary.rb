module Finance
  class BusinessCaseSummary
    include Summarizer

    def initialize(business_case)
      @business_case = business_case
    end

    def summarize
      financials_without_freeform.each_with_index.map do |financial_rule, index|
        summarize_rule(financial_rule, index)
      end
    end

    private

    def financials
      @financials ||= @business_case.financials
    end

    def transposed_financials
      financials_without_freeform.map { |f| f.values.flatten }.transpose
    end

    def freeform_row
      (financials.detect(&freeform_proc) || {}).values.flatten
    end

    def financials_without_freeform
      financials.reject(&freeform_proc)
    end

    def freeform_proc
      Proc.new do |financial_rule|
        financial_rule.keys.first == "freeform"
      end
    end
  end
end
