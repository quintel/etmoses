module Finance
  # Takes a BusinessCase and creates a CSV representation of the summary.
  class BusinessCaseCSVPresenter
    HEADERS = %i(stakeholder incoming outgoing freeform total).freeze

    def initialize(business_case)
      @business_case = business_case
    end

    def name
      [ @business_case.testing_ground.name,
        @business_case.testing_ground.id.to_s,
        'business_case.csv' ].join('.')
    end

    def headers
      { 'Content-Disposition' => "attachment; filename=\"#{ name }\"" }
    end

    def to_csv
      summary = Finance::BusinessCaseSummary.new(@business_case).summarize
      csv_headers = HEADERS.map { |s| s.to_s.titleize }

      CSV.generate(headers: csv_headers, write_headers: true) do |file|
        summary.each { |stakeholder| file << stakeholder.values_at(*HEADERS) }
      end
    end
  end # BusinessCaseCSVPresenter
end
