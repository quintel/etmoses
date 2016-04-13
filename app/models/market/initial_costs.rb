module Market
  # Calculates the costs to stakeholders of the technologies and infrastructure
  # for which they are responsible.
  #
  # Topology nodes belonging to a stakeholder with an investment_cost and
  # technical_lifetime will incur a cost to the stakeholder. Similarly,
  # technologies on endpoints with an initial_investment and technical_lifetime
  # will be billable to the stakeholder who owns the endpoint.
  class InitialCosts
    TOPOLOGY_REQUIRED = %i(investment_cost stakeholder)

    def initialize(network, gas_asset_list)
      @network        = network
      @gas_asset_list = gas_asset_list
    end

    def calculate
      [topology_costs, technology_costs, gas_assets_costs].inject do |total, costs|
        total.merge(costs) { |_, costs_a, costs_b| costs_a + costs_b }
      end
    end

    private

    # Private: A method that sums the initial costs for the chosen topology. These are
    # the costs that exist for the network itself.
    #
    # Returns a Hash
    def topology_costs
      group_sum(topology_nodes) do |node|
        ( node.get(:investment_cost).to_f / node.lifetime +
          node.get(:yearly_o_and_m_costs).to_f ) * node.units
      end
    end

    # Private: A method that sums the costs for the technologies that are attached
    # to the network.
    #
    # Returns a Hash
    def technology_costs
      group_sum(technology_nodes) do |node|
        node.techs.map(&:installed).sum(&:total_yearly_costs)
      end
    end

    # Private: Calculates the gas assets totals
    #
    # Returns a Hash
    def gas_assets_costs
      return {} if @gas_asset_list.nil?

      group_sum(GasAssetListDecorator.new(@gas_asset_list).decorate) do |asset|
        asset.total_investment_costs
      end
    end

    # Private: Sums specified nodes per unique stakeholder, with a specified
    # amount.
    #
    # Returns a Hash
    def group_sum(nodes)
      nodes.each_with_object(Hash.new(0.0)) do |node, data|
        data[node.stakeholder] += yield(node)
      end
    end

    def technology_nodes
      @network.nodes.select do |node|
        node.techs.map(&:installed).any?
      end
    end

    def topology_nodes
      @network.nodes.select do |node|
        TOPOLOGY_REQUIRED.all? { |attr| node.get(attr) } && node.lifetime
      end
    end
  end
end
