class TestingGround
  class TechnologyBuilder
    def initialize(options)
      @options       = options
      @key           = options.fetch(:key)
      @buffer        = options.fetch(:buffer)
      @scenario_id   = options.fetch(:scenario_id)
      @load_profiles = options.fetch(:load_profiles)
    end

    def build
      InstalledTechnology.new(installed_attributes)
    end

    private

    def installed_attributes
      technology.defaults
        .merge(imported_attributes)
        .merge(static_attributes)
    end

    def imported_attributes
      Import::TechnologyBuilder.build(@key, et_engine_stats.fetch(@key))
    end

    def static_attributes
      {
        name:       I18n.t("inputs.#{ technology.key }"),
        profile:    profile,
        includes:   technology.technologies,
        buffer:     @buffer,
        units:      1,
        components: components
      }
    end

    def components
      return [] unless technology.components

      technology.components.map do |component|
        Import::TechnologyBuilder.build(
          component, et_engine_stats.fetch(@key).slice('number_of_units'))
      end
    end

    def profile
      if technology.profile_required? && @load_profiles
        @load_profiles.first.id
      end
    end

    def technology
      Technology.find_by_key!(@key)
    end

    def et_engine_stats
      @et_engine_stats ||= begin
        if Technology.importable.map(&:key).include?(@key)
          EtEngineConnector.new(keys: [@key]).stats(@scenario_id)['nodes']
        else
          Hash[@key, {}]
        end
      end
    end
  end
end
