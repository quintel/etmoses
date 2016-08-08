module Market
  class InitialCosts
    class TopologyCosts < Costs
      def asset_list
        @networks[:electricity].nodes
          .map(&method(:decorate_node))
          .select(&:valid?)
      end

      alias_method :grouped_asset_list, :asset_list

      private

      def decorate_node(node)
        Market::NodeDecorator.new(node)
      end
    end
  end
end
