module Network
  module Heat
    # Describes a heat technology which produces heat energy as part of the
    # production park, for use by endpoints.
    class Producer < Technologies::Generic
      def initialize(*)
        super
        @assignments = DefaultArray.new { 0.0 }
      end

      def load
        @assignments
      end

      def consumer?
        false
      end

      def dispatchable?
        @installed.dispatchable
      end

      def must_run?
        ! dispatchable?
      end

      def production_at(frame)
        @profile ? super : capacity
      end

      # Public: Describes how much energy may be produced in the given frame.
      # Does not include energy which has been consumed already.
      #
      # Returns a float.
      def available_production_at(frame)
        production_at(frame) - @assignments[frame]
      end

      # Public: Instructs the producer than an `amount` of energy has been used.
      #
      # If the requested `amount` is more than can be satisfied by the producer,
      # only as much enery as can be produced will be taken. The actual amount
      # of energy used will be returned.
      #
      # Returns a float.
      def take(frame, amount)
        available = available_production_at(frame)
        amount    = available if available < amount

        if amount > 0
          @assignments[frame] += amount
          amount
        else
          0.0
        end
      end

      def capacity
        @capacity ||=
          Types::Capacity[@installed.heat_capacity] *
          Types::NumberOfUnits[@installed.units]
      end
    end # Producer
  end # Heat
end
