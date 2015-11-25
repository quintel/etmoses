class Import
  class DemandCalculator
    #
    # Calculates demand for a single entity
    # Could be a house or building
    #

    def initialize(scenario_id, number_of_units, gquery_keys)
      @scenario_id     = scenario_id
      @number_of_units = number_of_units.to_i
      @gquery_keys     = gquery_keys
    end

    def calculate
      DemandAttribute.call(calculation_data).round(2)
    end

    private

    def calculation_data
      { "demand" => {
          "future" => demand_for_scenario * 1_000_000_000
        },
        "number_of_units" => {
          "future" => @number_of_units
        }
      }
    end

    def demand_for_scenario
      if demand_gquery
        @gquery_keys.sum do |key|
          demand_gquery[key]['future'].to_f
        end
      else
        0
      end
    end

    def demand_gquery
      @demand_gquery ||= EtEngineConnector.new(gquery).gquery(@scenario_id)
    end

    def gquery
      { gqueries: @gquery_keys }
    end
  end
end
