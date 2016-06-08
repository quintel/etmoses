module HeatAssetLists
  class AssetListGenerator
    def initialize(testing_ground)
      @testing_ground = testing_ground
    end

    def generate
      [HeatAssets::Pipe.all, HeatAssets::Location.by_type('city_apartment')].flatten.map do |part|
        InstalledHeatAsset.new(create_heat_asset(part)).attributes
      end
    end

    private

    def create_heat_asset(part)
      {
        type:  part.type,
        scope: part.scope
      }
    end
  end
end
