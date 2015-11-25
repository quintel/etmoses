class Import
  class CompositeBuilder
    include Scaling

    COMPOSITE_ATTRS = %w(name key default_demand)

    def initialize(scaling)
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
        "composite" => true,
        "includes"  => technology.technologies.map(&:key) }
    end

    def translations
      { 'key' => 'type', 'default_demand' => 'demand' }
    end
  end
end
