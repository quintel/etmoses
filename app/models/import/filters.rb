class Import
  module Filters
    # Internal: checks if a certain technology is a hybrid
    #
    # Returns a boolean
    def hybrid?(technology)
      technology['carrier'] == 'hybrid'
    end

    def electric_vehicle?(technology)
      technology['type'] == 'transport_car_using_electricity'
    end

    def electric_water_heater?(technology)
      technology['type'] == 'households_water_heater_resistive_electricity'
    end
  end
end
