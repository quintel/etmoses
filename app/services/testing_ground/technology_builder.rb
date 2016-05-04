class TestingGround
  class TechnologyBuilder
    def initialize(options)
      @options       = options
      @key           = options.fetch(:key)
      @scenario_id   = options.fetch(:scenario_id)
      @load_profiles = options.fetch(:load_profiles)
    end

    def build
      InstalledTechnology.new(installed_attributes)
    end

    private

    def installed_attributes
      default_attributes.merge(imported_attributes).merge(static_attributes)
    end

    def default_attributes
      {
        demand:   technology.default_demand,
        volume:   technology.default_volume,
        capacity: technology.default_capacity
      }
    end

    def imported_attributes
      Import::TechnologyBuilder.build(@key, et_engine_stats.fetch(@key))
    end

    def static_attributes
      {
        name: name,
        profile: profile,
        includes: technology.technologies,
        units: 1
      }
    end

    def name
      technology.name
    end

    def profile
      if technology.profile_required? && @load_profiles
        @load_profiles.first.id
      end
    end

    def technology
      Technology.by_key(@key)
    end

    def et_engine_stats
      if Technology.importable.map(&:key).include?(@key)
        EtEngineConnector.new(keys: [@key]).stats(@scenario_id)['nodes']
      else
        Hash[@key, {}]
      end
    end
  end
end
