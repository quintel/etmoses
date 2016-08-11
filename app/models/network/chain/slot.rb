module Network
  module Chain
    # Describes the constraints on energy flowing through a Connection.
    #
    # A connection will have two Slots - one for energy moving from the top of
    # the network to the bottom (an "downward" slot) and one for energy moving
    # from the bottom to the top (an "upward" slot).
    #
    # Slots may have an optional `capacity`: a maximum amount of energy which
    # may flow through the connection in each frame. An `efficiency` will reduce
    # the energy flowing after the capacity constraint is applied.
    #
    # For example:
    #
    #   desired flow: 3.0
    #   capacity: 2.0
    #   efficiency: 0.9
    #
    # Flow through the connection will be 1.8: a capacity restriction of 2.0 is
    # limiting, which is then adjusted for efficiency.
    #
    # Examples
    #
    #   # A slot where energy flows from the bottom of the network to the top,
    #   # with 20% loss, and a maximum capacity of 2kW.
    #
    #   Slot.upward(efficiency: 0.8, capacity: 2.0)
    #
    #   # A slot where energy flows from the bottom of the network to the top,
    #   # with 50% loss, and no capacity limit.
    #
    #   Slot.downward(efficiency: 0.5)
    #
    class Slot
      include Equalizer.new(:capacity, :efficiency)

      class << self
        alias_method :upward, :new
        protected :new

        def downward(*args)
          Downward.new(*args)
        end
      end

      # Public: The capacity of the slot. Defaults to Infinity.
      attr_reader :capacity

      # Public: The efficiency of energy flowing through the slot. Defaults to
      # 1.0.
      attr_reader :efficiency

      def initialize(capacity: Float::INFINITY, efficiency: 1.0)
        @capacity   = Types::Capacity[capacity]
        @efficiency = Types::Efficiency[efficiency]
      end

      # Public: Given an `amount` of energy, applies the efficiency and capacity
      # constraints, returning the amount of energy which will leave on the
      # other side of the connection.
      #
      # Returns a numeric.
      def call(amount)
        constrain(apply_efficiency(amount))
      end

      # Public: Determines how much energy will be lost by passing `amount`
      # through the slot.
      #
      # Returns a Float.
      def loss(amount)
        (amount - apply_efficiency(amount)).abs
      end

      # Public: Depending on the direction of the slot, constrained energy
      # represents energy being discarded (upward slots) or a deficit (downward
      # slots).
      #
      # amount - The total amount of energy being sent through the slot.
      #
      # Returns a Float.
      def constrained(amount)
        post_loss = apply_efficiency(amount)
        post_loss - constrain(post_loss)
      end

      private

      def apply_efficiency(amount)
        amount * @efficiency
      end

      def constrain(amount)
        amount < @capacity ? amount : @capacity
      end

      # Represents a Slot where energy is flowing from the top of the network
      # (high pressure) to the bottom (lower pressure).
      class Downward < self
        def call(amount)
          apply_efficiency(constrain(amount))
        end

        def loss(amount)
          post_cons = constrain(amount)
          (post_cons - apply_efficiency(post_cons)).abs
        end

        def constrained(amount)
          amount - constrain(amount)
        end

        private def apply_efficiency(amount)
          amount / @efficiency
        end
      end
    end # Slot
  end # Chain
end
