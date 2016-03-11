class Import
  class CompositeBuilder
    include Scaling

    COMPOSITE_ATTRS = %w(name key default_demand)

    DEMAND_MAPPING = {
      'buffer_space_heating' => 'etmoses_space_heating_buffer_demand',
      'buffer_water_heating' => 'etmoses_hot_water_buffer_demand'
    }.freeze

    def initialize(scenario_id, scaling)
      @scenario_id = scenario_id
      @scaling = scaling
    end

    def build
      return [] unless valid_scaling?

      Technology.where(composite: true).map do |technology|
        transform(technology.attributes.slice(*COMPOSITE_ATTRS))
          .merge(composite_attributes(technology))
      end
    end

    private

    def transform(attributes)
      Hash[attributes.map do |key, value|
        [ translations[key] || key, value ]
      end]
    end

    def composite_attributes(technology)
      { "units"     => scaling_value,
        "type"      => technology.key,
        "name"      => technology.name,
        "composite" => true,
        "includes"  => technology.technologies,
        "demand"    => demand_for(technology) }
    end

    def translations
      { 'key' => 'type', 'default_demand' => 'demand' }
    end

    def demand_for(technology)
      Import::DemandCalculator.new(
        @scenario_id, scaling_value, [DEMAND_MAPPING[technology.key.to_s]]
      ).calculate
    end
  end
end
