class Import
  module TechnologyBuilder
    # Extracts number_of_units from the raw data.
    NumberOfUnitsAttribute = Attribute.new('number_of_units')

    # Internal: A hash of attributes which may be imported from ETEngine.
    ATTRIBUTES = Hash[[ DemandAttribute,
                        ElectricityOutputCapacityAttribute,
                        InputCapacityAttribute ].map do |attribute|
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
      units      = NumberOfUnitsAttribute.call(data).round
      technology = Technology.by_key(key)
      attribute  = self.attribute(technology.import_from)

      { 'type'               => key,
        'name'               => technology.name,
        'units'              => units,
        attribute.local_name => attribute.call(data) }
    end
  end
end
