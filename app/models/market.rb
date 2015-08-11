require_relative 'market/errors'

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
  #       'Stakeholder 2' => [Network::Node, Network::Node, ...]
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
  #
  # Returns a Market::Graph.
  def self.build(data)
    Market::Builder.new(data).to_market
  end

  # Public: Like +build+, creates a new Market graph, but does so based on a
  # given MarketModel record and calculated network graph.
  #
  # For example:
  #
  #   market = Market.from_market_model(
  #     MarketModel.last,
  #     TestingGround.last.to_calculated_graph
  #   )
  #
  #   # Show the price of each relation.
  #   market.relations.each do |relation|
  #     puts [relation, relation.price]
  #   end
  #
  #   # Relations contain information about who is paying whom, and the
  #   # foundation used.
  #   relation = market.relations.first
  #
  #   relation.from.key  # The payer.
  #   relation.to.key    # The payee.
  #   relation.label     # The name of the tariff.
  #   relation.price     # The price to be paid.
  #
  # Returns a Market::Graph
  def self.from_market_model(model, les)
    Market::FromMarketModelBuilder.new(model, les).to_market
  end
end # Market
