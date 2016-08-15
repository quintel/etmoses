module Market
  class InitialCosts
    class TechnologyCosts < Costs
      def calculate
        group_sum(technology_nodes) do |node|
          technologies_for_node(node).sum do |tech|
            # "Internal" technologies (such as the central heat buffer) will not
            # define any cost methods.
            tech.try(:total_yearly_costs)
          end
        end
      end

      private

      def technology_nodes
        @networks.flat_map do |_, network|
          network.nodes.select { |node| node.techs.map(&:installed).any? }
        end
      end

      def technologies_for_node(node)
        @testing_ground.technology_profile.list[node.key] || []
      end
    end
  end
end
