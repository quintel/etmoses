module Market
  class InitialCosts
    class TechnologyCosts < Costs
      def calculate
        seen = {}

        group_sum(technology_nodes) do |node|
          if seen[node.key]
            # If the same node exists in multiple networks, we don't need to
            # calculate costs again.
            0.0
          else
            seen[node.key] = true

            technologies_for_node(node).sum do |tech|
              # "Internal" technologies (such as the central heat buffer) will
              # not define any cost methods.
              tech.try(:total_yearly_costs)
            end
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
