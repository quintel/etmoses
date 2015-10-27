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
      get(:measurables) || []
    end

    # Public: Determines the price of the relation.
    #
    # Returns a numeric.
    def price
      rule.call(self, get(:variants))
    rescue Market::Error => ex
      ex.message.gsub!(/$/, " (in #{ inspect })")
      raise ex
    end
  end
end
