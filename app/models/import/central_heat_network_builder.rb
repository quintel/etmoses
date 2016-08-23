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
      defaults = technology.defaults.merge('key' => technology.key)

      attributes = technology.importable_gqueries
        .each_with_object(defaults) do |(attr, query), hash|
          hash[attr] = ATTRIBUTES[query].call(gqueries)
        end

      # Must-runs need a profile; since there is normally only one instance of
      # each must-run, assign the first suitable profile.
      if (profile = TechnologyProfile.where(technology: technology.key).first)
        attributes['units']   = 1.0
        attributes['profile'] = profile.load_profile_id
      end

      attributes
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
