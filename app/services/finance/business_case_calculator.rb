module Finance
  class BusinessCaseCalculator
    include StakeholderFetcher

    def initialize(testing_ground, strategies = nil)
      @testing_ground = testing_ground
      @strategies     = strategies
      @stakeholders   = fetch_stakeholders
    end

    def rows
      @stakeholders.map do |column_header|
        Hash[ column_header, cells(column_header) ]
      end
    end

    private

    def strategies
      @strategies.presence || @testing_ground.selected_strategy.attributes
    end

    def cells(column_header)
      @stakeholders.map do |stakeholder|
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
      @market ||= begin
        Market.from_market_model(
          @testing_ground,
          networks[:electricity],
          gas:       Market::Variant.new { networks[:gas] },
          basic:     featureless_networks[:electricity],
          basic_gas: featureless_networks[:gas],
        )
      end
    end

    def networks
      @networks ||= Hash[
        @testing_ground.to_calculated_graphs(strategies: @strategies).map do |network|
          [network.carrier, network]
        end
      ]
    end

    def initial_business_case_costs
      @initial_costs ||= Market::InitialCosts.new(
        networks[:electricity], @testing_ground.gas_asset_list
      ).calculate
    end

    # A variant of the network with all storage, flexibility, and other special
    # features turned off. Used in the flexibility measures.
    def featureless_networks
      @featureless_networks ||= begin
        # Lazily computes the featureless networks only when required.

        featureless = Market::Variant.new do
          @testing_ground.to_calculated_graphs
        end

        electricity = Market::Variant.new do
          featureless.object.detect { |net| net.carrier == :electricity }
        end

        gas = Market::Variant.new do
          featureless.object.detect { |net| net.carrier == :gas }
        end

        { electricity: electricity, gas: gas }
      end
    end
  end
end
