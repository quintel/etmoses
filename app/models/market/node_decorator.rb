module Market
  class NodeDecorator
    include BusinessCaseCosts

    TOPOLOGY_REQUIRED = %i(investment_cost stakeholder)

    def initialize(node)
      @node = node
    end

    def valid?
      TOPOLOGY_REQUIRED.all? { |attr| @node.get(attr) } && @node.lifetime
    end

    def stakeholder
      @node.get(:stakeholder)
    end

    def technical_lifetime
      @node.lifetime
    end

    def units
      @node.units
    end

    def initial_investment
      @node.get(:investment_cost).to_f
    end

    def om_costs_per_year
      @node.get(:yearly_o_and_m_costs).to_f
    end

    def yearly_variable_om_costs
      0
    end
  end
end
