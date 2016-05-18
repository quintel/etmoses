module Market
  class InitialCosts
    class TechnologyCosts < Costs
      # Public: A method that sums the costs for the technologies that are attached
      # to the network.
      #
      # Returns a Hash
      def calculate
        group_sum(technology_nodes) do |node|
          node.techs.map(&:installed).sum(&:total_yearly_costs)
        end
      end

      private

      def technology_nodes
        @network.nodes.select do |node|
          node.techs.map(&:installed).any?
        end
      end
    end
  end
end
