class Import
  class HouseBuilder
    include Scaling

    #
    # Builds houses from an ETM scaling attribute
    #
    def initialize(scenario_id, scaling)
      @scenario_id = scenario_id
      @scaling = scaling
    end

    def build
      return [] unless valid_scaling?

      [{ "name"     => "Household",
         "type"     => "base_load",
         "profile"  => nil,
         "capacity" => nil,
         "demand"   => average_demand,
         "units"    => scaling_value }]
    end

    def average_demand
      @average_demand ||= Import::DemandCalculator.new(
        @scenario_id,
        scaling_value,
        ["etmoses_electricity_base_load_demand"]
      ).calculate
    end
  end
end
