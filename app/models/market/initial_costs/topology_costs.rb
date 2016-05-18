module Market
  class InitialCosts
    class TopologyCosts < Costs
      TOPOLOGY_REQUIRED = %i(investment_cost stakeholder)

      def calculate
        group_sum(topology_nodes) do |node|
          ( node.get(:investment_cost).to_f / node.lifetime +
            node.get(:yearly_o_and_m_costs).to_f ) * node.units
        end
      end

      private

      def topology_nodes
        @network.nodes.select do |node|
          TOPOLOGY_REQUIRED.all? { |attr| node.get(attr) } && node.lifetime
        end
      end
    end
  end
end
