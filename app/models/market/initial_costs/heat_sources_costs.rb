module Market
  class InitialCosts
    class HeatSourcesCosts < Costs
      def grouped_asset_list
        HeatSourceListDecorator.new(asset_list).decorate
      end

      private

      def asset_list
        @asset_list ||= @testing_ground.heat_source_list
      end
    end
  end
end
