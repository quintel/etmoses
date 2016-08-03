class Import
  class DefaultTechnologyBuilder < Builder
    include Filters

    def build(response)
      response
        .reject(&method(:hybrid?))
        .reject(&method(:electric_vehicle?))
        .reject(&method(:electric_water_heater?))
    end
  end
end
