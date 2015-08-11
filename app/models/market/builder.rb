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
  #         foundation: :kwh,
  #         tariff: 10.0
  #       }
  #     }
  #   }
  class Builder
    FOUNDATIONS = {
      connections:    Foundations::NumberOfConnections,
      flex_potential: Foundations::FlexibilityPotential,
      flex_realised:  Foundations::FlexibilityRealised,
      load:           Foundations::InstantaneousLoad,
      kw_contracted:  ->(*) { 0.0 },
      kw_max:         Foundations::KwMax.new,
      kwh:            Foundations::Kwh.new,
      kwh_consumed:   Foundations::KwhConsumed,
      kwh_produced:   Foundations::KwhProduced
    }.freeze

    # Public: Creates a builder, which converts a "set-up hash" into a market
    # model.
    def initialize(data)
      @market = Graph.new
      @data   = data
    end

    # Public: Creates and returns the Market::Graph based on the data with which
    # the Builder was initialized.
    def to_market
      @data[:relations].each do |relation_data|
        build_relation!(relation_data)
      end

      set_measurables!

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

      from.connect_to(
        to, relation[:name] || relation[:foundation],
        rule: Market::PaymentRule.new(
          foundation_from(relation), tariff_from(relation[:tariff])))
    end

    # Internal: Sets the market nodes which are measured by the relation.
    def set_measurables!
      return unless @data[:measurables]

      @data[:measurables].each do |key, measurables|
        @market.node(key) && @market.node(key).set(:measurables, measurables)
      end
    end

    # Internal: Given data about a relation, determines the foundation object
    # to be used to compute the price.
    def foundation_from(relation)
      foundation =
        if relation[:foundation].respond_to?(:call)
          relation[:foundation]
        else
          FOUNDATIONS[relation[:foundation]]
        end

      fail NoSuchFoundationError, relation[:foundation] unless foundation

      foundation
    end

    # Internal: Creates the Tariff object to be used in a payment rule.
    def tariff_from(tariff)
      case tariff
        when Tariff  then tariff
        when Numeric then Tariff.new(tariff)
        else              fail(InvalidTariffError.new(tariff))
      end
    end
  end # Builder
end
