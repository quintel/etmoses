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
  def self.build(data)#, network)
    fail Error, "Invalid data: #{ data.inspect }" if data.blank?
    Market::Builder.new(data).to_market
  end
end # Market
