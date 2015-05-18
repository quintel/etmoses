class Import
  class HouseBuilder
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
         "units"    => @scaling['value'].to_i }]
    end

    def average_demand
      @average_demand ||= Demand.new(@scenario_id,
                                     @scaling["value"].to_i).calculate
    end

    private

      def valid_scaling?
        @scaling && @scaling['area_attribute'] == 'number_of_residences'
      end
  end
end
