module Finance
  class BusinessCaseValidator
    def initialize(topology, market_model)
      @topology = topology
      @market_model = market_model
    end

    def valid?
      (topology_stakeholders & applied_to_stakeholders).sort ==
        applied_to_stakeholders.sort
    end

    private

    def topology_stakeholders
      @topology.each_node.map { |node| node[:stakeholder] }
    end

    def applied_to_stakeholders
      @market_model.interactions.map{ |i| i['applied_stakeholder'] }.uniq
    end
  end
end
