module Network
  module Technologies
    class Buffer < Storage
      attr_accessor :stored

      def self.disabled?(options)
        false
      end

      def self.disabled_class
        self
      end

      def self.build(installed, profile, options)
        if installed.buffer.blank? && ! options[:no_legacy_fallback]
          LegacyBuffer.build(installed, profile, options)
        else
          super
        end
      end

      def initialize(installed, profile, buffering_space_heating: false, **)
        super

        @buffering  = buffering_space_heating
        @mand_loads = []
        @cond_loads = []
      end

      def stored
        @stored ||= Reserve.new
      end

      # Public: Production describes the amount stored in the buffer at the
      # start of the frame, minus that consumed by the use profile. If use
      # exceeds the amount stored, the deficit goes unmet.
      #
      # Returns a numeric.
      def production_at(frame)
        0.0
      end

      # Public: The minimum amount of energy required to fulfil the needs of the
      # buffer in this time step. This minimum is defined by the availability
      # profile which specifies how full the buffer should be at the end of the
      # frame.
      #
      # Returns a numeric.
      def mandatory_consumption_at(frame)
        @mand_loads[frame] ||= begin
          # Force evaluation of energy taken from buffer.
          stored.at(frame)

          @capacity.limit_mandatory(
            frame,
            @profile.at(frame) / @installed.performance_coefficient
          )
        end
      end

      # Public: Determines how much extra the buffer may consume in order to
      # fill the attached Reserve futher.
      #
      # Returns a numeric.
      def conditional_consumption_at(frame)
        return 0.0 unless @buffering

        @cond_loads[frame] ||= begin
          @capacity.limit_conditional(
            frame,
            stored.unfilled_at(frame) / @installed.performance_coefficient
          )
        end
      end

      # Public: EVs should not overload the network.
      def capacity_constrained?
        true
      end

      # Public: EV conditional load may come from the grid.
      def excess_constrained?
        false
      end

      def store(frame, amount)
        stored.add(frame, amount * @installed.performance_coefficient)
      end
    end # Buffer
  end
end
