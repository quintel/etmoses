class Import
  class BuildingsBuilder < Builder
    #
    # Given a scenario, returns the amount of buildings for the current scenario
    # Also calculates the average demand of a single building
    #

    NUMBER_OF_BUILDINGS = 'number_of_buildings'

    def build(_response)
      return [] if no_buildings?

      [{ 'name'     => 'Buildings',
         'type'     => 'base_load_buildings',
         'profile'  => nil,
         'capacity' => nil,
         'demand'   => demand,
         'units'    => number_of_buildings }]
    end

    private

    def demand
      Import::DemandCalculator.new(
        @scenario_id,
        number_of_buildings,
        @gqueries.slice('present_demand_in_source_of_electricity_in_buildings')
      ).calculate
    end

    def number_of_buildings
      @gqueries.fetch(NUMBER_OF_BUILDINGS).fetch('present').to_i
    end

    def no_buildings?
      @gqueries[NUMBER_OF_BUILDINGS].blank?
    end
  end
end
