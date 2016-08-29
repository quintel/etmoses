module Network
  module Technologies
    class Buffer < Storage
      attr_accessor :stored

      def self.disabled?(options)
        ! options[:solar_power_to_heat]
      end

      def self.disabled_class
        Generic
      end

      def initialize(installed, profile, **)
        super
        @receipts = Receipts.new
      end

      def stored
        @stored ||= Reserve.new
      end

      # Public: Production describes the amount stored in the buffer at the
      # start of the frame, minus that consumed by the use profile. If use
      # exceeds the amount stored, the deficit goes unmet.
      #
      # Returns a numeric.
      def production_at(_frame)
        0.0
      end

      # Public: The minimum amount of energy required to fulfil the needs of the
      # buffer in this time step. This minimum is defined by the availability
      # profile which specifies how full the buffer should be at the end of the
      # frame.
      #
      # Returns a numeric.
      def mandatory_consumption_at(frame)
        # Force evaluation of energy taken from buffer.
        stored.at(frame)

        wanted = @profile.at(frame) / @installed.performance_coefficient

        # SubPath will remove from the request any energy which has already been
        # delivered. This is because other technologies will always return their
        # full demand even after part of that demand has been satisfied. Buffer
        # however will compute the amount of energy still needed, accounting for
        # that supplied by other members of the composite. Therefore we add the
        # "receipt" back to the demand in order to counteract the SubPath.
        wanted += @receipts.mandatory[frame]

        @capacity.limit_mandatory(frame, wanted)
      end

      # Public: Determines how much extra the buffer may consume in order to
      # fill the attached Reserve futher.
      #
      # Returns a numeric.
      def conditional_consumption_at(frame)
        wanted = stored.unfilled_at(frame) / @installed.performance_coefficient

        # See `mandatory_consumption_at`.
        wanted += @receipts.conditional[frame]

        @capacity.limit_conditional(frame, wanted)
      end

      # Public: Buffers should not overload the network.
      def capacity_constrained?
        true
      end

      # Public: Buffering loads may come only from excess local energy.
      def excess_constrained?
        true
      end

      def receive_mandatory(frame, amount)
        super
        @receipts.mandatory[frame] += amount
      end

      def store(frame, amount)
        stored.add(frame, amount * @installed.performance_coefficient)
        @receipts.conditional[frame] += amount
      end
    end # Buffer
  end
end
