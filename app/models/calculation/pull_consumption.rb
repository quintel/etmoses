module Calculation
  # Calculates consumption flows through the network.
  #
  # Based on the output of producers, we can determine how much excess or
  # deficit is available in the network in a given time-step. This excess is
  # then distributed fairly between the storage technologies.
  module PullConsumption
    def self.call(context)
      root  = context.graph.nodes.detect { |node| node.edges(:in).none? }
      paths = context.paths

      context.frames do |frame|
        paths.each do |path|
          # Push mandatory flows through the network.
          path.consume(frame, path.mandatory_consumption_at(frame))
        end

        excess = root.production_at(frame) - root.consumption_at(frame)

        paths.each do |path|
          break if excess <= 0.0

          wanted     = path.conditional_consumption_at(frame)
          assignable = excess < wanted ? excess : wanted

          path.consume(frame, assignable)

          excess -= assignable
        end
      end

      context
    end
  end # PullConsumption
end # Calculation
