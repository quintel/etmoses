module Market
  class InitialCosts
    REQUIRED = %i(investment_cost technical_lifetime stakeholder)

    def initialize(network)
      @network = network
    end

    def calculate
      technology_costs.merge(topology_costs) do |_, tech_cost, topology_cost|
        tech_cost + topology_cost
      end
    end

    private

    def topology_costs
      group_sum(topology_nodes) do |node|
        node.get(:investment_cost) / node.get(:technical_lifetime)
      end
    end

    def technology_costs
      group_sum(technology_nodes) do |node|
        node.techs.map(&:installed).sum do |tech|
          tech.initial_investment / tech.technical_lifetime
        end
      end
    end

    def group_sum(nodes)
      Hash[nodes.group_by{|node| node.get(:stakeholder) }.map do |_, nodes|
        [_, nodes.sum do |node|
          yield(node)
        end]
      end]
    end

    def technology_nodes
      @network.nodes.select do |node|
        node.techs.map(&:installed).any? do |tech|
          tech.initial_investment && tech.technical_lifetime
        end
      end
    end

    def topology_nodes
      @network.nodes.select do |node|
        REQUIRED.all?{|attr| node.get(attr) }
      end
    end
  end
end
