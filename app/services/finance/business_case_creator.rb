module Finance
  class BusinessCaseCreator
    def initialize(testing_ground)
      @testing_ground = testing_ground
      @business_case = @testing_ground.business_case
    end

    def create
      unless existing_business_case?
        @business_case = BusinessCase.create!(testing_ground: @testing_ground)
        calculate
      end
      @business_case
    end

    def calculate
      return unless existing_business_case?

      @business_case.update_attribute(:financials, financials)
      @business_case
    end

    private

    def existing_business_case?
      @business_case.present?
    end

    def financials
      (Finance::BusinessCaseCalculator.new(@testing_ground).rows + [existing_freeform]).compact
    end

    def existing_freeform
      if financials = @business_case.financials
        financials.last
      end
    end
  end
end
