module Network
  module Technologies
    # Represents a generic technology within the testing ground, which may have
    # a capacity and profile, or a constant load.
    class Generic
      def self.build(installed, profile, options)
        new(installed, profile, **options)
      end

      attr_reader :installed, :profile

      def initialize(installed, profile, **)
        @installed = installed
        @profile   = profile
      end

      # TODO: The name of this method suggests it checks to see if there is a
      # capacity restriction preventing fulfilment; that's not the case. Find a
      # better name.
      def capacity_constrained?
        false
      end

      def excess_constrained?
        false
      end

      def load_at(frame)
        @profile.at(frame)
      end

      def consumption
        @consumption ||= []
      end

      # Public: Determines the minimum amount of energy the technology consumes
      # in a given time-step.
      #
      # Mandatory consumption describes the amount of load which must be
      # assigned to the technology, regardless of excesses or deficits in the
      # network.
      #
      # If the mandatory load of all consumers in the network exceeds total
      # production, the deficit will be supplied from the external grid.
      #
      # Returns a numeric.
      def mandatory_consumption_at(frame)
        consumer? ? load_at(frame) : 0.0
      end

      # Public: Determines the extra amount of energy the technology *may*
      # consume in addition to its mandatory load.
      #
      # Conditional load describes extra load which a technology may want if
      # there is an excess of production in the network. A common example might
      # be the remaining capacity in a battery, which should be fulfilled if
      # there is enough excess elsewhere.
      #
      # Returns a numeric.
      def conditional_consumption_at(_frame)
        0.0
      end

      def flexible_conditional?
        true
      end

      def conservable_production_at(frame)
        0.0
      end

      # Public: Determines the energy produced by the technology in the given
      # time-step.
      #
      # Returns a numeric.
      def production_at(frame)
        producer? ? load_at(frame).abs : 0.0
      end

      def capacity
        (@installed.capacity || 0.0) *
          @installed.units / @installed.performance_coefficient
      end

      # Public: If this technology may store/buffer energy for later use, how
      # much may it keep at once?
      #
      # In the front-end, volume is defined in kilowatt-hours. Here in the
      # Network we instead model the volume as kilowatt-frames. If the curve
      # resolution is one frame-per-hour, the two values are identical.
      #
      # For example, if we have one frame-per-hour, and a volume of 10 kWh, the
      # `volume` method returns 10. If the tech then stores ten consecutive 1 kW
      # loads the volume will be full.
      #
      # If we have four frames-per-hour (one per-15-minutes), the `volume`
      # method now returns 40. It can store 40 consecutive 1kW loads; this is
      # the exact same load-over-time as the previous example except now we are
      # measuring 15 minute periods instead of 60.
      #
      # Returns a numeric.
      def volume
        ((@installed.volume || Float::INFINITY) /
          (@installed.performance_coefficient || 1.0)) *
          @installed.units * @profile.frames_per_hour
      end

      def consumer?
        capacity.present? && capacity >= 0 ||
          @installed.demand ||
          # When storage is disabled, it may turn into a normal technology in
          # order to draw load -- but NOT store -- from the network.
          @installed.volume
      end

      def producer?
        ! consumer?
      end

      def storage?
        false
      end

      def store(_frame, _amount)
      end
    end # Generic
  end
end
