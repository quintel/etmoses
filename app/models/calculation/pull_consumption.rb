module Calculation
  # Calculates consumption flows through the network.
  #
  # Based on the output of producers, we can determine how much excess or
  # deficit is available in the network in a given time-step. This excess is
  # then distributed fairly between the storage technologies.
  module PullConsumption
    module_function

    # Public: Computes energy flows through the network.
    #
    # Returns the context.
    def call(context)
      context.frames do |frame|
        mandatory_consumption!(frame, context)
        non_excess_conditional_consumption!(frame, context)
        excess_conditional_consumption!(frame, context)
        conservable_production!(frame, context)
      end

      context
    end

    # --

    # Internal: Push mandatory flows through the network.
    #
    # Returns nothing.
    def mandatory_consumption!(frame, context)
      context.paths.each do |path|
        path.consume(frame, path.mandatory_consumption_at(frame))
      end
    end

    private_class_method :mandatory_consumption!

    # Internal: Technologies which are do not care about excesses, and may take
    # energy from the grid, come next.
    #
    # Returns nothing.
    def non_excess_conditional_consumption!(frame, context)
      context.paths.each do |path|
        unless path.excess_constrained?
          path.consume(frame, path.conditional_consumption_at(frame), true)
        end
      end
    end

    private_class_method :non_excess_conditional_consumption!

    # Internal: Compute the loads of technologies whose conditional loads are
    # only satisfied when there is enough production in the LES.
    #
    # Returns nothing.
    def excess_conditional_consumption!(frame, context)
      excess = context.head.production_at(frame) -
        context.head.consumption_at(frame)

      context.paths.each do |path|
        next unless path.excess_constrained?

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
    end

    private_class_method :excess_conditional_consumption!

    # Internal: Send loads through the network where over-production results in
    # a (negative) capacity exceedance.
    #
    # Returns nothing.
    def conservable_production!(frame, context)
      return unless context.options[:strategies][:capping_solar_pv]

      context.paths.each do |path|
        conservable = path.technology.conservable_production_at(frame)

        if path.congested_at?(frame) && conservable > 0
          exceedance = path.production_exceedance_at(frame)
          amount     = conservable < exceedance ? conservable : exceedance

          path.consume(frame, amount, true)
        end
      end
    end

    private_class_method :conservable_production!
  end # PullConsumption
end # Calculation
