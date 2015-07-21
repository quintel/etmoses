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
          if excess <= 0
            # Some technologies need to be explicitly told that they received
            # nothing, as they have further actions to take.
            path.consume(frame, 0.0, true)
          else
            wanted     = path.conditional_consumption_at(frame)
            assignable = excess < wanted ? excess : wanted

            path.consume(frame, assignable, true)

            excess -= assignable
          end
        end

        # Method for solar capping
        if context.options[:capping_solar_pv]
          paths.each do |path|
            conservable = path.technology.conservable_production_at(frame)

            #
            # Check if path is congested and if conservable production is higher than 0
            # Conservable defaults to 0 for non-solar-PV

            if path.congested_at?(frame) && conservable > 0
              #
              # Exceedance is the largest exceedance in the current path

              exceedance = path.production_exceedance_at(frame)

              amount = conservable < exceedance ? conservable : exceedance

              path.consume(frame, amount, true)
            end
          end
        end
      end

      context
    end
  end # PullConsumption
end # Calculation
