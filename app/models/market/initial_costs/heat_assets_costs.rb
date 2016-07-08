module Market
  class InitialCosts
    class HeatAssetsCosts < Costs
      def grouped_asset_list
        HeatAssetListDecorator.new(asset_list).decorate
      end

      private

      def asset_list
        @asset_list ||= @testing_ground.heat_asset_list
      end
    end
  end
end

