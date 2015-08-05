class Import
  class BuildingsBuilder
    #
    # Given a scenario, returns the amount of buildings for the current scenario
    # Also calculates the average demand of a single building
    #

    def initialize(scenario_id)
      @scenario_id = scenario_id
    end

    def build
      return [] if no_buildings?

      [{ "name"     => "Buildings",
         "type"     => "base_load_buildings",
         "profile"  => nil,
         "capacity" => nil,
         "demand"   => demand,
         "units"    => number_of_buildings }]
    end

    private

    def demand
      Import::DemandCalculator.new(
        @scenario_id,
        number_of_buildings,
        "present_demand_in_source_of_electricity_in_buildings"
      ).calculate
    end

    def number_of_buildings
      buildings_gquery['present'].to_i
    end

    def no_buildings?
      buildings_gquery.blank?
    end

    def buildings_gquery
      @buildings_gquery ||= EtEngineConnector.new({
        gqueries: ["number_of_buildings"]
      }).gquery(@scenario_id)
    end
  end
end
