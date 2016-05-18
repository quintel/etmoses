module Market
  class InitialCosts
    class Costs
      def initialize(network, testing_ground)
        @network = network
        @testing_ground = testing_ground
      end

      def self.calculate(network, testing_ground)
        self.new(network, testing_ground).calculate
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
