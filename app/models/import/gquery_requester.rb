class Import
  class GqueryRequester
    def initialize(technologies)
      @technologies = technologies
    end

    def request(etm_scenario)
      EtEngineConnector.new(gqueries: gquery_keys.compact.flat_map(&:values).sort)
        .gquery(etm_scenario.fetch(:id))
    end

    private

    def gquery_keys
      @technologies.flat_map do |tech|
        Technology.by_key(tech).importable_gqueries
      end
    end
  end
end
