module HeatAssetLists
  class AssetListGenerator
    def initialize(testing_ground)
      @testing_ground = testing_ground
    end

    def generate
      heat_pipes + heat_locations
    end

    private

    def heat_pipes
      HeatAssets::Pipe.all.map do |part|
        part.attributes
      end
    end

    def heat_locations
      [ HeatAssets::Location.by_type('city_apartment') ].map do |part|
        part.attributes
      end
    end
  end
end
