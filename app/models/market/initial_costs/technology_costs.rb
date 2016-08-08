module Market
  class InitialCosts
    class TechnologyCosts < Costs
      def calculate
        group_sum(technology_nodes) do |node|
          node.techs.map(&:installed).sum do |tech|
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
    end
  end
end
