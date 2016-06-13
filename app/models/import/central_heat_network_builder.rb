class Import
  class CentralHeatNetworkBuilder
    TECHNOLOGIES = %w(central_heat_network_dispatchable
                      central_heat_network_must_run)

    ATTRIBUTES = Hash[
      [ CentralHeatNetworkDispatchableCapacityAttribute,
        CentralHeatNetworkMustRunHeatProductionAttribute].map do |attr|
          [attr.remote_name, attr]
        end
    ]

    def initialize(scenario_id)
      @scenario_id = scenario_id
    end

    def self.build(scenario_id)
      self.new(scenario_id).build_technologies
    end

    def build_technologies
      technologies.map(&method(:build_technology))
    end

    private

    def build_technology(technology)
      defaults = technology_defaults(technology).merge('key' => technology.key)

      technology.importable_gqueries
        .each_with_object(defaults) do |(attr, query), hash|
          hash[attr] = ATTRIBUTES[query].call(gqueries)
        end
    end

    # TODO: needs to be cleaned up
    def technology_defaults(technology)
      defaults = technology.defaults.dup
      defaults.update('total_initial_investment' =>
                      (defaults['total_initial_investment'] / 1000))
    end

    def technologies
      @technologies ||= Technology.all.select do |technology|
        TECHNOLOGIES.include?(technology.key)
      end
    end

    def gqueries
      @gqueries ||= GqueryRequester.new(TECHNOLOGIES).request(id: @scenario_id)
    end
  end
end
