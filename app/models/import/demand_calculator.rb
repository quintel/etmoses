class Import
  class DemandCalculator
    #
    # Calculates demand for a single entity
    # Could be a house or building
    #

    def initialize(scenario_id, number_of_units, gquery_result)
      @scenario_id     = scenario_id
      @number_of_units = number_of_units.to_i
      @gquery_result   = gquery_result
    end

    def calculate
      DemandAttribute.call(calculation_data)
    end

    private

    def calculation_data
      {
        'demand' => {
          'future' => demand_for_scenario * 1_000_000_000
        },
        'number_of_units' => {
          'future' => @number_of_units
        }
      }
    end

    def demand_for_scenario
      if @gquery_result.any?
        @gquery_result.sum { |_, key| key['future'].to_f }
      else
        0
      end
    end
  end
end
