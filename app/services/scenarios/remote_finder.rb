module Scenarios
  class RemoteFinder
    SCENARIO_PATH = "http://#{Settings.etengine_host}/" \
                    "api/v3/scenarios/templates"

    # Public: find all scenarios sort them by title
    def find_remote_scenarios
      scenarios.sort do |a,b|
        a[0] <=> b[0]
      end
    end

    private

    # Internal: Map only the title and the id from the scenarios from +request+
    def scenarios
      request.map do |scenario|
        [scenario['title'], scenario['id']]
      end
    end

    # Internal: request all templates from et-engine
    def request
      JSON.parse(RestClient.get(SCENARIO_PATH))
    end
  end
end
