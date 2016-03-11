class Import
  module TechnologyBuilder
    # Extracts number_of_units from the raw data.
    NumberOfUnitsAttribute = Attribute.new('number_of_units')
    InitialInvestmentAttribute = Attribute.new('initial_investment')
    TechnicalLifetimeAttribute = Attribute.new('technical_lifetime')
    FullLoadHoursAttribute = Attribute.new('full_load_hours')

    # Internal: A hash of attributes which may be imported from ETEngine.
    ATTRIBUTES = Hash[[ DemandAttribute,
                        ElectricityOutputCapacityAttribute,
                        InputCapacityAttribute,
                        StorageVolumeAttribute,
                        InitialInvestmentAttribute,
                        TechnicalLifetimeAttribute,
                        CoefficientOfPerformanceAttribute,
                        FullLoadHoursAttribute,
                        FixedOmCostsPerYearAttribute,
                        VariableOmCostsCcsPerFullLoadHourAttribute,
                        VariableOmCostsPerFullLoadHourAttribute ].map do |attribute|
      [attribute.remote_name, attribute]
    end].with_indifferent_access.freeze

    # Public: Retrieves the Attribute responsible for importing the given
    # ETEngine attribute key.
    def self.attribute(key)
      ATTRIBUTES[key]
    end

    # Public: Given a technology key, data from ETEngine, and an enumerator
    # which yields suitable profiles, constructs an array representing the
    # technology in the testing ground.
    #
    # Returns an array of hashes.
    def self.build(key, data)
      units = NumberOfUnitsAttribute.call(data).round
      tech  = Technology.by_key(key)
      attrs = { 'type'    => key,
                'name'    => tech.name,
                'units'   => units,
                'carrier' => tech.carrier,
                'position_relative_to_buffer' => tech.default_position_relative_to_buffer }

      tech.importable_attributes.map(&method(:attribute))
        .each { |attr| attrs[attr.local_name] = attr.call(data) }

      attrs
    end
  end
end
