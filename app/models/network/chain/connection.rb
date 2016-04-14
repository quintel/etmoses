module Network
  module Chain
    # Links two layers with capacity and efficincy restrictions, depending on
    # the direction in which energy is flowing.
    class Connection
      include Component

      attr_reader :upward, :downward

      # Public: Creates a new Connection with the given `upward` and `downward`
      # Slots.
      def initialize(upward:, downward:)
        super()

        @upward   = upward
        @downward = downward

        @input = []
      end

      # Needed for `source_at`.
      alias_method :orig_call, :call

      # Public: Computes (and remembers) how much energy is flowing through the
      # connection in the given frame.
      #
      # Returns a numeric.
      def call(frame)
        @load[frame] ||= begin
          amount   = source_at(frame)#@input[frame] = super
          adjusted = active_slot(amount).call(amount.abs)

          amount < 0 ? -adjusted : adjusted
        end
      end

      # Public: Calculates how much energy is lost in the given `frame`.
      #
      # Loss is always a postive, regardless of the direction in which energy is
      # flowing.
      #
      # Returns a Float.
      def loss_at(frame)
        amount = source_at(frame)
        active_slot(amount).loss(amount.abs)
      end

      # Public: Determines how much energy is constrained in the given `frame`.
      #
      # "Constrained" energy is that which is discarded when flowing up (gas is
      # "flared") and is returned as a negative, while constrained energy
      # flowing downwards represents a deficit.
      #
      # Returns a Float.
      def constrained_at(frame)
        amount      = source_at(frame)
        constrained = active_slot(amount).constrained(amount.abs)

        amount < 0 ? -constrained : constrained
      end

      private

      def source_at(frame)
        @input[frame] ||= orig_call(frame)
      end

      def active_slot(amount)
        amount < 0 ? @upward : @downward
      end
    end # Connection
  end # Chain
end
