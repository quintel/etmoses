module Market
  class InitialCosts
    REQUIRED = %i(investment_cost technical_lifetime stakeholder)

    def initialize(les)
      @les = les
    end

    def calculate
      binding.pry

    end

    private

    def topology_costs
      Hash[topology_nodes.map do |node|
        [node, node.get(:investment_cost) / node.get(:technical_lifetime) ]
      end]
    end

    def technology_costs
      Hash[technology_nodes.map do |node, techs|
        [ node,
          techs.sum do |tech|
            if tech.initial_investment && tech.technical_lifetime
              tech.initial_investment / tech.technical_lifetime
            else
              0
            end
          end ]
      end]
    end

    def technology_nodes
      Hash[ @les.nodes.select{ |node| node.techs.any? }
                      .map{ |node| [ node, node.techs.map(&:installed) ] } ]
    end

    def topology_nodes
      @les.nodes.select do |node|
        REQUIRED.all?{|attr| node.get(attr) }
      end
    end
  end
end
