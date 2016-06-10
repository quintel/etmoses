module HeatAssetLists
  class AssetListGenerator
    def initialize(testing_ground)
      @testing_ground = testing_ground
    end

    def generate
      heat_pipes + heat_locations
    end

    # Public: heat_pipes
    #
    # Generates a list of heat pipes used in the heat asset list. Is looseley
    # based of the amount of sources specified in the heat source list.
    #
    def heat_pipes
      HeatSourceListDecorator.new(@testing_ground.heat_source_list)
        .decorate.map do |heat_source_list|
          HeatAssets::Pipe.all.first.attributes.merge(
            distance:    heat_source_list.distance,
            heat_source: heat_source_list.key
          )
        end
    end

    private

    def heat_locations
      [ HeatAssets::Location.by_type('city_apartment') ].map do |part|
        part.attributes.merge(connection_distribution: 1.0)
      end
    end
  end
end
