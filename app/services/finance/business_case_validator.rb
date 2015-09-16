module Finance
  class BusinessCaseValidator
    def initialize(topology, market_model)
      @topology = topology
      @market_model = market_model
    end

    def valid?
      (topology_stakeholders & applied_to_stakeholders) == applied_to_stakeholders
    end

    private

    def topology_stakeholders
      stakeholders = []
      @topology.each_node do |node|
        stakeholders << node[:stakeholder]
      end
      stakeholders.compact.uniq
    end

    def applied_to_stakeholders
      @market_model.interactions.map{|i| i['applied_stakeholder'] }.uniq
    end
  end
end
