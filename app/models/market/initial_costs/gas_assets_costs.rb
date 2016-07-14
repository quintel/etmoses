module Market
  class InitialCosts
    class GasAssetsCosts < Costs
      def grouped_asset_list
        GasAssetListDecorator.new(asset_list).decorate
      end

      private

      def asset_list
        @asset_list ||= @testing_ground.gas_asset_list
      end
    end
  end
end
