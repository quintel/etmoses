module Market
  # Calculates the costs to stakeholders of the technologies and infrastructure
  # for which they are responsible.
  #
  # Topology nodes belonging to a stakeholder with an investment_cost and
  # technical_lifetime will incur a cost to the stakeholder. Similarly,
  # technologies on endpoints with an initial_investment and technical_lifetime
  # will be billable to the stakeholder who owns the endpoint.
  class InitialCosts
    INITIAL_COSTS = [
      TopologyCosts, TechnologyCosts, GasAssetsCosts, HeatSourcesCosts
    ].freeze

    def initialize(network, testing_ground)
      @network        = network
      @testing_ground = testing_ground
    end

    def calculate
      INITIAL_COSTS.map(&method(:calculate_costs)).inject do |total, costs|
        total.merge(costs) do |_, costs_a, costs_b|
          costs_a + costs_b
        end
      end
    end

    def calculate_costs(costs)
      costs.calculate(@network, @testing_ground)
    end
  end
end
