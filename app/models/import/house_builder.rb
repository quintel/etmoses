class Import
  class HouseBuilder < BaseBuilder
    #
    # Builds houses from an ETM scaling attribute
    #
    def build(_response)
      [{ 'type'     => 'base_load',
         'profile'  => nil,
         'capacity' => nil,
         'demand'   => average_demand,
         'units'    => number_of_residences }]
    end

    def average_demand
      @average_demand ||= Import::DemandCalculator.new(
        @scenario_id,
        number_of_residences,
        @gqueries.slice('etmoses_electricity_base_load_demand')
      ).calculate
    end
  end
end
