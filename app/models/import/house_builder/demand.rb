class Import
  class HouseBuilder
    class Demand
      #
      # Calculates demand for a single house
      #

      def initialize(scenario_id, number_of_households)
        @scenario_id = scenario_id
        @number_of_households = number_of_households.to_i
      end

      def calculate
        DemandAttribute.call({
          "demand" => { "future" => demand_for_scenario * 1_000_000_000 },
          "number_of_units" => {"future" => @number_of_households }
        }).round(2)
      end

      private

        def demand_for_scenario
          if scenario_demand_request
            JSON.parse(scenario_demand_request)\
              ["gqueries"]\
              ["final_demand_of_electricity_in_households"]\
              ["future"]
          else
            0
          end
        end

        def scenario_demand_request
          @scenario_demand_request ||= begin
            RestClient.put(scenario_demand_url,
              {gqueries: ["final_demand_of_electricity_in_households"]}.to_json,
              {content_type: :json, accept: :json})
          rescue RestClient::ResourceNotFound
            nil
          end
        end

        def scenario_demand_url
          ETM_URLS[:scenario] % [ TestingGround::IMPORT_PROVIDERS.first,
                                  @scenario_id ]
        end
    end
  end
end
