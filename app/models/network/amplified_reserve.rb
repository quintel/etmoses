module Network
  # A reserve which has two volumes: a "low-energy" volume which is filled like
  # a normal reserve, and a "high-energy" volume which may receive energy only
  # under exceptional circumstances.
  class AmplifiedReserve < Reserve
    # Public: Creates a new amplified reserve.
    #
    # low   - The maximum amount of energy which may be stored in the low-energy
    #         state.
    # high  - The maximum amount of energy which may be stored in the reserve in
    #         the high-energy state.
    # decay - A proc which computes energy decay for each frame. See
    #         Reserve#initialize.
    #
    # Returns an AmplifiedReserve.
    def initialize(low = Float::INFINITY, high = low, &decay)
      @low_volume = low
      super(high, &decay)
    end

    # Public: Returns the reserve wrapped in a HighEnergyMode wrapper. All calls
    # to the reserve will be in high-energy mode.
    #
    # Returns a HighEnergyMode.
    def high_energy
      HighEnergyMode.new(self)
    end

    # Public: Returns how much of the reserve is unfilled.
    #
    # Returns a numeric.
    def unfilled_at(frame, high_energy = false)
      stored = at(frame)

      if high_energy
        @volume - stored
      else
        unfilled = @low_volume - stored
        unfilled > 0 ? unfilled : 0.0
      end
    end

    # Public: Adds the given `amount` of energy in your chosen `frame`, ensuring
    # that the reserve does not exceed capacity. An optional `high_energy` param
    # instructs the reserve to also use the high-energy buffer.
    #
    # Return the amount of energy which was added; note that this may be lesss
    # than was set in the `amount` parameter.
    def add(frame, amount, high_energy = false)
      unfilled = unfilled_at(frame, high_energy)
      amount   = amount < unfilled ? amount : unfilled

      super(frame, amount)
    end

    # Public: A human readable version of the reserve for debugging.
    def inspect
      "#<#{ self.class.name } " \
        "low_volume=#{ @low_volume } high_volume=#{ @volume }>"
    end

    # Public: A human readable version of the reserve.
    def to_s
      "#{ self.class.name }{#{ @low_volume }, #{ @volume }}"
    end

    # A Reserve-compatible wrapper around AmplifiedReserve which enables the
    # high-energy volume by default.
    class HighEnergyMode < FastDelegator.create(AmplifiedReserve)
      def unfilled_at(frame)
        super(frame, true)
      end

      def add(frame, amount)
        super(frame, amount, true)
      end
    end
  end # AmplifiedReserve
end
