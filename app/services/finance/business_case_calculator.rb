module Finance
  class BusinessCaseCalculator
    def initialize(testing_ground)
      @testing_ground = testing_ground
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
        @testing_ground.to_calculated_graph
      )
    end
  end
end
