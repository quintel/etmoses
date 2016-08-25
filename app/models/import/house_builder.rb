class Import
  class HouseBuilder < BaseBuilder
    include Scaling

    #
    # Builds houses from an ETM scaling attribute
    #
    def build(_response)
      return [] unless valid_scaling?

      [{ 'type'     => 'base_load',
         'profile'  => nil,
         'capacity' => nil,
         'demand'   => average_demand,
         'units'    => scaling_value }]
    end

    def average_demand
      @average_demand ||= Import::DemandCalculator.new(
        @scenario_id,
        scaling_value,
        @gqueries.slice('etmoses_electricity_base_load_demand')
      ).calculate
    end
  end
end
