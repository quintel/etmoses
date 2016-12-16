module Market
  class InitialCosts
    class HeatAssetsCosts < Costs
      def grouped_asset_list
        HeatAssetListDecorator.new(asset_list).decorate.each do |asset|
          if asset.secondary?
            asset.number_of_units = asset.connection_distribution * heat_connections
          end
        end
      end

      private

      def heat_connections
        @heat_connections ||= begin
          Market::Measures::NumberOfHeatConnections.count_with_technology_profile(
            @testing_ground.technology_profile
          )
        end
      end

      def asset_list
        @asset_list ||= @testing_ground.heat_asset_list
      end
    end
  end
end

