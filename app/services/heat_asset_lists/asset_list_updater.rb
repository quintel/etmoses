module HeatAssetLists
  class AssetListUpdater
    def initialize(testing_ground)
      @testing_ground  = testing_ground
      @heat_asset_list = testing_ground.heat_asset_list
    end

    def update!
      @heat_asset_list.update_attribute(:asset_list, asset_list)
    end

    private

    def asset_list
      [ AssetListGenerator.new(@testing_ground).heat_pipes,
        heat_asset_list.select(&method(:is_location?)).map(&:attributes)
      ].flatten
    end

    def heat_asset_list
      HeatAssetListDecorator.new(@heat_asset_list).decorate
    end

    def is_location?(heat_tech)
      heat_tech.is_a?(InstalledHeatAssetLocation)
    end
  end
end
