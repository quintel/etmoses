module HeatAssetLists
  class AssetListUpdater
    def initialize(testing_ground)
      @testing_ground = testing_ground
    end

    def update!
      @testing_ground.heat_asset_list.update_attribute(:asset_list, new_asset_list)

      heat_asset_list
    end

    private

    def new_asset_list
      [ AssetListGenerator.new(@testing_ground).heat_pipes,
        heat_asset_list.select(&method(:is_location?)).map(&:attributes)
      ].flatten
    end

    def heat_asset_list
      HeatAssetListDecorator.new(
        @testing_ground.heat_asset_list).decorate
    end

    def is_location?(heat_tech)
      heat_tech.is_a?(InstalledHeatAssetLocation)
    end
  end
end
