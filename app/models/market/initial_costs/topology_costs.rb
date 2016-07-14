module Market
  class InitialCosts
    class TopologyCosts < Costs
      def asset_list
        @network.nodes.map(&method(:decorate_node)).select do |node|
          node.valid?
        end
      end

      alias_method :grouped_asset_list, :asset_list

      private

      def decorate_node(node)
        Market::NodeDecorator.new(node)
      end
    end
  end
end
