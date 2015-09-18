module Market
  # Connects two stakeholders, describing an interaction; typically energy for
  # money.
  class Relation < Turbine::Edge
    # Public: Retrieves the payment rule for this relation.
    def rule
      get(:rule)
    end

    # Public: The nodes whose values should be measured in order to determine
    # the price of the relation. These are the network nodes belonging to the
    # leaf nodes in the market graph.
    #
    # Returns an array of Network::Node instances.
    def measurables
      @measurables ||= to.ancestors(label)
        .select { |n| n.in_edges.none? }
        .get(:measurables).uniq.to_a
    end

    # Public: Determines the price of the relation.
    #
    # Returns a numeric.
    def price
      get(:rule).call(self, get(:variants))
    end
  end
end
