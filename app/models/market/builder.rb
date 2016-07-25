module Market
  # Public: Creates a new market graph.
  #
  # Expects data to describe the stakeholders in the marketplace, along with
  # their interactions and payment rules.
  #
  # Expects a hash in the form:
  #
  #   {
  #     measurables: {
  #       'Stakeholder 2': [Network::Node, Network::Node, ...],
  #     },
  #     relations: {
  #       {
  #         name: :kwh, # Optional
  #         from: 'Stakeholder 1',
  #         to: 'Stakeholder 2',
  #         measure: :kwh,
  #         tariff: 10.0
  #       }
  #     }
  #   }
  class Builder
    MEASURES = {
      connections:       Measures::NumberOfConnections,
      flex_potential:    Measures::FlexibilityPotential,
      flex_realised:     Measures::FlexibilityRealised,
      gas_connections:   Measures::NumberOfGasConnections,
      gas_kwh_consumed:  Measures::VariantKwh.new(:gas, :consumed),
      gas_kwh_produced:  Measures::VariantKwh.new(:gas, :produced),
      heat_kwh_consumed: Measures::VariantKwh.new(:heat, :consumed),
      heat_kwh_produced: Measures::ParkKwhProduced,
      heat_connections:  Measures::NumberOfHeatConnections,
      load:              Measures::InstantaneousLoad,
      kw_contracted:     Measures::KwMax.new(1),
      kw_max:            Measures::KwMax.new,
      kwh_consumed:      Measures::KwhConsumed,
      kwh_produced:      Measures::KwhProduced
    }.freeze

    # Public: Creates a builder, which converts a "set-up hash" into a market
    # model.
    def initialize(data)
      fail Error, "Invalid data: #{ data.inspect }" if data.blank?

      @market = Graph.new
      @data   = data
    end

    # Public: Creates and returns the Market::Graph based on the data with which
    # the Builder was initialized.
    def to_market
      @data[:relations].each do |relation_data|
        build_relation!(relation_data)
      end

      @market
    end

    private

    # Internal: Retrieves the named stakeholder. Creates and adds it to the
    # market model if it does not already exist.
    def stakeholder(name)
      @market.node(name) || @market.add(Market::Stakeholder.new(name))
    end

    # Internal: Sets a relationship between two stakeholders.
    #
    # Returns the Relation.
    def build_relation!(relation)
      from = stakeholder(relation[:from])
      to   = stakeholder(relation[:to])

      rule = Market::PaymentRule.new(
        measure_from(relation),
        tariff_from(relation[:tariff]),
        relation[:detector]
      )

      from.connect_to(
        to,

        # Assign a random edge label.
        #
        # The use of Turbine no longer makes much sense for the market model,
        # and will eventually be replaced. In the meantime, using a random label
        # fixes #449.
        SecureRandom.uuid,

        measure:     relation[:measure],
        detector:    relation[:detector],
        measurables: relation[:measurables],
        variants:    @data[:variants],
        rule:        rule
      )
    end

    # Internal: Given data about a relation, determines the measure object to be
    # used to compute the price.
    def measure_from(relation)
      measure =
        if relation[:measure].respond_to?(:call)
          relation[:measure]
        else
          MEASURES[relation[:measure]]
        end

      fail NoSuchMeasureError, relation[:measure] unless measure

      measure
    end

    # Internal: Creates the Tariff object to be used in a payment rule.
    def tariff_from(tariff)
      case tariff
        when Tariff         then tariff
        when Numeric        then Tariff.new(tariff)
        when Network::Curve then CurveTariff.new(tariff)
        else
          fail(InvalidTariffError.new(tariff))
      end
    end
  end # Builder
end
