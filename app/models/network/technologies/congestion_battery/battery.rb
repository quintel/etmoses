module Network::Technologies
  module CongestionBattery
    class Battery < Storage
      def self.disabled?(options)
        ! options[:battery_storage]
      end

      def path_class
        CongestionBattery::TechnologyPath
      end

      def initialize(installed, *)
        super

        @soft_min = volume * (installed.congestion_reserve_percentage / 100) / 2
        @soft_max = volume - @soft_min
      end

      # Public: Returns the "production" of the battery in the given frame; this
      # is the amount of energy which is stored in the battery. Mandatory
      # consumption may reclaim some of this to ensure that the capacity of the
      # battery is not exceeded.
      #
      # Returns a float.
      def production_at(frame)
        # Force the first point in the year to be equal to the soft min so that
        # the battery starts partially-charged.
        frame.zero? ? @soft_min : stored[frame - 1]
      end

      def conditional_consumption_at(frame, path)
        # We want to draw at least soft_min in order to get out of the lower
        # congestion zone, or enough to eliminate as much of the production
        # congestion as possible; whichever is greater.

        conditional_min = @soft_min - mandatory_consumption_at(frame)
        p_exceed = path.production_exceedance_at(frame)
        wanted   = conditional_min > p_exceed ? conditional_min : p_exceed

        # We then want to apply as much of the surplus as possible, but not so
        # much as to enter the upper congestion zone (we may have already done
        # so when trying to eliminate the production exceedance).

        conditional_max = @soft_max - mandatory_consumption_at(frame)
        wanted = conditional_max if wanted < conditional_max

        # Finally, if there is a consumption exceedance, we reduce the load so
        # as to fix that.

        wanted -= path.consumption_exceedance_at(frame, wanted)
        @capacity.limit_conditional(frame, wanted < 0 ? 0.0 : wanted)
      end

      def excess_constrained?
        false
      end

      def capacity_constrained?
        false
      end

      def emit_retain?
        true
      end
    end
  end # CongestionBattery
end # Network::Technologies
