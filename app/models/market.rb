require_relative 'market/errors'

module Market
  class << self
    # Public: Creates a new market graph.
    #
    # Expects data to describe the stakeholders in the marketplace, along with
    # their interactions and payment rules.
    #
    # Expects a hash in the form:
    #
    #   {
    #     stakeholders: [
    #       { name: 'Stakeholder 1' },
    #       { name: 'Stakeholder 2' }
    #     ],
    #     relations: [
    #       { from: 'Stakeholder 1', to: 'Stakeholder 2' }
    #     ]
    #   }
    #
    # Returns a Turbine::Graph.
    def build(data)
      market = Turbine::Graph.new

      fail Error, "Invalid data: #{ data.inspect }" if data.blank?

      build_stakeholders!(market, data[:stakeholders] || {})
      build_relations!(market, data[:relations] || {})

      market
    end

    #######
    private
    #######

    def build_stakeholders!(market, stakeholders)
      stakeholders.each do |stakeholder|
        market.add(Turbine::Node.new(
          stakeholder[:name],
          stakeholder: Market::Stakeholder.new(stakeholder[:name]),
        ))
      end
    end

    def build_relations!(market, relations)
      relations.each do |relation|
        from = market.node(relation[:from])
        to   = market.node(relation[:to])

        fail NoSuchStakeholderError, relation[:from] unless from
        fail NoSuchStakeholderError, relation[:to]   unless to

        from.connect_to(to)
      end
    end
  end # class << self
end # Market
