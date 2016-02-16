class TestingGround
  class TechnologyBuilder
    def initialize(key, scenario_id)
      @key = key
      @scenario_id = scenario_id
    end

    def build
      InstalledTechnology.new(
        Import::TechnologyBuilder.build(@key, et_engine_stats.fetch(@key))
      ).attributes
    end

    private

    def et_engine_stats
      EtEngineConnector.new(keys: [@key]).stats(@scenario_id)['nodes']
    end
  end
end
