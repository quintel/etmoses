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
        row(column_header, stakeholder)
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
        @testing_ground.market_model,
        @testing_ground.to_calculated_graph(@strategies),
        basic: featureless_network
      )
    end

    # A variant of the network with all storage, flexibility, and other special
    # features turned off. Used in the flexibility measures.
    def featureless_network
      Market::Variant.new(&@testing_ground.method(:to_calculated_graph))
    end
  end
end
