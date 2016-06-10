class Import
  module Technologies
    class Fetcher
      # Move to db/static/technologies/
      #
      TECHNOLOGIES_FOR_GQUERIES = %w(
        base_load
        base_load_buildings
        buffer_space_heating
        buffer_water_heating
        transport_car_using_electricity
      )

      def initialize(etm_scenario)
        @etm_scenario = etm_scenario
        @scenario_id  = etm_scenario.fetch(:id)
      end

      def fetch
        builders.flat_map do |builder|
          builder.new(gqueries, @etm_scenario).build(technologies_from)
        end
      end

      private

      # Internal: Imports the requested data from the remote provider and
      # returns the JSON response as a Hash.
      def response
        @response ||= EtEngineConnector.new(keys: keys)
                      .stats(@scenario_id)['nodes']
      end

      def keys
        #Hash[technologies.map do |technology|
        #  [technology.key, technology.importable_attributes]
        #end]
        Technology.importable.map(&:key)
      end

      def technologies_for_gqueries
        Technology.all.select do |tech|
          TECHNOLOGIES_FOR_GQUERIES.include?(tech.key)
        end
      end

      # Internal: Given a response, splits out the nodes into discrete
      # technologies.
      #
      # Returns an array.
      def technologies_from
        @technologies_from ||= response.flat_map do |key, data|
          TechnologyBuilder.build(key, data)
        end
      end

      def gqueries
        @gqueries ||= Import::GqueryRequester.new(
          technologies_for_gqueries.map(&:key)
        ).request(@etm_scenario)
      end

      def builders
        [
          Import::HouseBuilder,
          Import::CompositeBuilder,
          Import::BuildingsBuilder,
          Import::ElectricVehicleBuilder,
          Import::HybridBuilder,
          Import::DefaultTechnologyBuilder
        ]
      end
    end
  end
end
