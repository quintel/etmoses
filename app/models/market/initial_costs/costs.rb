module Market
  class InitialCosts
    class Costs
      def initialize(networks, testing_ground)
        @networks = networks
        @testing_ground = testing_ground
      end

      def self.calculate(networks, testing_ground)
        self.new(networks, testing_ground).calculate
      end

      def calculate
        return {} if asset_list.nil?

        group_sum(grouped_asset_list) do |asset|
          asset.total_yearly_costs
        end
      end

      # Private: Sums specified nodes per unique stakeholder, with a specified
      # amount.
      #
      # Returns a Hash
      def group_sum(nodes)
        nodes.each_with_object(Hash.new(0.0)) do |node, data|
          data[get_stakeholder(node)] += yield(node)
        end
      end

      def get_stakeholder(node)
        node.is_a?(Network::Node) ? node.get(:stakeholder) : node.stakeholder
      end
    end
  end
end
