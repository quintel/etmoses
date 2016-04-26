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

      class Path < TechnologyPath
        # Public: Returns the sub-paths to the head node.
        def sub_paths
          # The congestion battery currently does not work correctly if computed
          # multiple times; as a result, we have to limit it to only resolving
          # congestion problems on the parent node.
          @sub_paths ||= [super[1]]
        end

        # Internal: A copy of the sub-path between the head network node and the
        # technology. Used to take energy from the grid.
        def full_sub_path
          # This is a SubPath, without the special features of
          # CongestionSubPath.
          @full_sub_path = SubPath.from(self).last
        end

        def conditional_consumption_at(frame)
          constrain(frame, @technology.conditional_consumption_at(frame, self))
        end

        private def sub_path_class
          CongestionSubPath
        end
      end # Path

      class CongestionSubPath < SubPath
        def conditional_consumption_at(frame)
          amount    = @technology.conditional_consumption_at(frame, self)
          available = @full_path.consumption_margin_at(frame)

          amount < available ? amount : available
        end

        def consume(frame, amount, conditional = false)
          return if amount < 1e-10

          excess = excess_at(frame)

          if amount > excess
            # Consume using the full path however much is not available as
            # excess; this energy is coming from the HV network.
            @full_path.full_sub_path.consume(frame, amount - excess, conditional)
            super(frame, excess, conditional)
          else
            super
          end
        end

        def negative_storage_tech_load?
          length == 2 && @full_path.technology.try(:emit_retain?)
        end
      end # CongestionSubPath
    end # CongestionBattery
  end
end
