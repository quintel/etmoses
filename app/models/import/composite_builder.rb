class Import
  class CompositeBuilder < Builder
    include Scaling

    COMPOSITE_ATTRS = %w(name key default_demand)

    DEMAND_MAPPING = {
      'buffer_space_heating' => 'etmoses_space_heating_buffer_demand',
      'buffer_water_heating' => 'etmoses_hot_water_buffer_demand'
    }.freeze

    def build(_response)
      return [] unless valid_scaling?

      Technology.where(composite: true).map do |technology|
        transform(technology.attributes.slice(*COMPOSITE_ATTRS))
          .merge(composite_attributes(technology))
      end
    end

    def composite_attributes(technology)
      { 'units'     => scaling_value,
        'type'      => technology.key,
        'name'      => technology.name,
        'composite' => true,
        'includes'  => technology.technologies,
        'demand'    => demand_for(technology),
        'volume'    => technology.default_volume
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
        @scenario_id, scaling_value,
        @gqueries.slice(DEMAND_MAPPING[technology.key.to_s])
      ).calculate
    end
  end
end
