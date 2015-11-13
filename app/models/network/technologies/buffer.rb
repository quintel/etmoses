module Network
  module Technologies
    class Buffer < Storage
      def self.disabled?(options)
        ! options[:buffering_space_heating]
      end

      attr_accessor :stored

      def self.disabled_class
        Generic
      end

      def stored
        @stored ||= Reserve.new# { |frame, _| @profile.at(frame) }
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
        wanted = @profile.at(frame)

        if frame.zero?
          wanted
        elsif stored.at(frame).zero? && wanted > 0
          # Nothing is left in the buffer and we have consumption, perhaps the
          # buffer did not have enough to satisfy demand...
          wanted - stored.decay_at(frame)
        else
          # Demand was satisfied.
          0.0
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

      def receive_mandatory(frame, amount)
        @stored.add(frame, amount)
      end
    end # Buffer
  end
end
