class Import
  class CompositeBuilder < BaseBuilder
    COMPOSITE_ATTRS = %w(name key default_demand)

    DEMAND_MAPPING = {
      'buffer_space_heating' => 'etmoses_space_heating_buffer_demand',
      'buffer_water_heating' => 'etmoses_hot_water_buffer_demand'
    }.freeze

    def build(_response)
      Technology.where(composite: true).map do |technology|
        transform(technology.attributes.slice(*COMPOSITE_ATTRS))
          .merge(composite_attributes(technology))
      end
    end

    def composite_attributes(technology)
      { 'units'     => number_of_residences,
        'type'      => technology.key,
        'composite' => true,
        'demand'    => demand_for(technology),
        'volume'    => technology.defaults.fetch("volume")
      }
    end

    private

    def transform(attributes)
      Hash[attributes.map do |key, value|
        [translations[key] || key, value]
      end]
    end

    def translations
      { 'key' => 'type', 'default_demand' => 'demand' }
    end

    def demand_for(technology)
      Import::DemandCalculator.new(
        @scenario_id, number_of_residences,
        @gqueries.slice(DEMAND_MAPPING[technology.key.to_s])
      ).calculate
    end
  end
end
