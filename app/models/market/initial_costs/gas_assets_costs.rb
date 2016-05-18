module Market
  class InitialCosts
    class GasAssetsCosts < Costs
      # Private: Calculates the gas assets totals
      #
      # Returns a Hash
      def calculate
        return {} if gas_asset_list.nil?

        group_sum(GasAssetListDecorator.new(gas_asset_list).decorate) do |asset|
          asset.total_investment_costs
        end
      end

      private

      def gas_asset_list
        @gas_asset_list ||= @testing_ground.gas_asset_list
      end
    end
  end
end
