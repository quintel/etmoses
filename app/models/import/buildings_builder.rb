class Import
  class BuildingsBuilder < BaseBuilder
    #
    # Given a scenario, returns the amount of buildings for the current scenario
    # Also calculates the average demand of a single building
    #

    NUMBER_OF_BUILDINGS = 'etmoses_number_of_buildings'.freeze

    def build(_response)
      return [] if no_buildings?

      [{ 'type'     => 'base_load_buildings',
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
        @gqueries.slice('etmoses_electricity_base_load_demand_for_buildings')
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
