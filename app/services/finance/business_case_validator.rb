module Finance
  class BusinessCaseValidator
    def initialize(topology_template, market_model_template)
      @topology_template = topology_template
      @market_model_template = market_model_template
    end

    def valid?
      (topology_template_stakeholders & applied_to_stakeholders).sort ==
        applied_to_stakeholders.sort
    end

    private

    def topology_template_stakeholders
      @topology_template.each_node.map { |node| node[:stakeholder] }
    end

    def applied_to_stakeholders
      @market_model_template.interactions.map{ |i| i['applied_stakeholder'] }.uniq
    end
  end
end
