module Finance
  class BusinessCaseCalculator
    def initialize(testing_ground, strategies = {})
      @testing_ground = testing_ground
      @strategies = strategies
    end

    def rows
      stakeholders.map do |column_header|
        Hash[ column_header, cells(column_header) ]
      end
    end

    def stakeholders
      Stakeholder.all.sort
    end

    private

    def cells(column_header)
      stakeholders.map do |stakeholder|
        if stakeholder == column_header
          (row(column_header, stakeholder) || 0) +
          (initial_business_case_costs[stakeholder] || 0)
        else
          row(column_header, stakeholder)
        end
      end
    end

    def row(header, stakeholder)
      rels = market.relations.select do |rel|
        rel.from.key == stakeholder && rel.to.key == header
      end

      rels.any? ? rels.sum(&:price) : nil
    end

    def market
      @market ||= Market.from_market_model(
        @testing_ground, network, basic: featureless_network
      )
    end

    def network
      @network ||= @testing_ground.to_calculated_graph(@strategies)
    end

    def initial_business_case_costs
      @initial_costs ||= Market::InitialCosts.new(network).calculate
    end

    # A variant of the network with all storage, flexibility, and other special
    # features turned off. Used in the flexibility measures.
    def featureless_network
      Market::Variant.new(&@testing_ground.method(:to_calculated_graph))
    end
  end
end
