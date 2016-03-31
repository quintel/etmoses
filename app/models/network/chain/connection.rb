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
      end

      # Public: Computes (and remembers) how much energy is flowing through the
      # connection in the given frame.
      #
      # Returns a numeric.
      def call(frame)
        @load[frame] ||= begin
          amount   = super
          slot     = amount < 0 ? @upward : @downward
          adjusted = slot.call(amount.abs)

          amount < 0 ? -adjusted : adjusted
        end
      end
    end # Connection
  end # Chain
end
