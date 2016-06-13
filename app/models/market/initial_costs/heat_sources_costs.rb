module Market
  class InitialCosts
    class HeatSourcesCosts < Costs
      # Private: Calculates the gas assets totals
      #
      # Returns a Hash
      def calculate
        return {} if heat_source_list.nil?

        group_sum(HeatSourceListDecorator.new(heat_source_list).decorate) do |asset|
          asset.depreciation_costs
        end
      end

      private

      def heat_source_list
        @heat_source_list ||= @testing_ground.heat_source_list
      end
    end
  end
end
