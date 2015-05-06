module Calculation
  # Calculates consumption flows through the network.
  #
  # Based on the output of producers, we can determine how much excess or
  # deficit is available in the network in a given time-step. This excess is
  # then distributed fairly between the storage technologies.
  module PullConsumption
    def self.call(context)
      root  = context.graph.nodes.detect { |node| node.edges(:in).none? }
      paths = context.technology_nodes.map { |node| Network::Path.find(node) }

      context.points do |point|
        paths.each do |path|
          # Push mandatory flows through the network.
          path.consume(point, path.mandatory_consumption_at(point))
        end

        excess = root.production_at(point) - root.consumption_at(point)

        # If there is an excess, push as much of it as possible towards
        # consumers which may want more (storage).
        if excess > 0
          wanted = paths.sum { |path| path.conditional_consumption_at(point) }

          if wanted > 0
            assignable = excess < wanted ? excess : wanted

            paths.each do |path|
              share  = path.conditional_consumption_at(point) / wanted
              amount = assignable * share

              path.consume(point, amount)
            end
          end
        end
      end

      context
    end
  end # PullConsumption
end # Calculation
