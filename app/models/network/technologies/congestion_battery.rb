module Network
  module Technologies
    class CongestionBattery < Storage
      def self.disabled?(options)
        ! options[:battery_storage]
      end

      def path_class
        CongestionBattery::Path
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

        if (surplus = (path.surplus_at(frame) - wanted)) > 0
          conditional_max = @soft_max - mandatory_consumption_at(frame)

          if wanted + surplus > conditional_max
            wanted = conditional_max
          else
            wanted += surplus
          end
        end

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

      class Path < TechnologyPath
        def conditional_consumption_at(frame)
          constrain(frame, @technology.conditional_consumption_at(frame, self))
        end
      end
    end # CongestionBattery
  end
end
