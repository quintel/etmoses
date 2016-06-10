module Market
  class InitialCosts
    class HeatAssetsCosts < Costs
      # Private: Calculates the gas assets totals
      #
      # Returns a Hash
      def calculate
        return {} if heat_asset_list.nil?

        group_sum(HeatAssetListDecorator.new(heat_asset_list).decorate) do |asset|
          asset.depreciation_costs
        end
      end

      private

      def heat_asset_list
        @heat_asset_list ||= @testing_ground.heat_asset_list
      end
    end
  end
end

