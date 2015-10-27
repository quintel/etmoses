module Network
  # Stores energy for later use. Has an optional volume which may not be
  # exceeded.
  class Reserve
    def initialize(volume = Float::INFINITY)
      @volume = volume
      @store  = []
    end

    # Public: Returns how much energy is stored in the reserve at the end of the
    # given frame. If the technology to which the reserve is attached is still
    # being calculated, the energy stored may be subject to change.
    #
    # Returns a numeric.
    def at(frame)
      @store[frame] ||= frame.zero? ? 0.0 : at(frame - 1)
    end

    alias_method :[], :at

    # Public: Sets the `amount` in the reserve for the given `frame`. Ignores
    # volume constraints, and assumes you know what you're doing.
    #
    # Returns the amount.
    def set(frame, amount)
      @store[frame] = amount
    end

    alias_method :[]=, :set

    # Public: Adds the given `amount` of energy in your chosen `frame`, ensuring
    # that the reserve does not exceed capacity.
    #
    # Return the amount of energy which was added; note that this may be lesss
    # than was set in the `amount` parameter.
    def add(frame, amount)
      stored = at(frame)
      amount = @volume - stored if (stored + amount) > @volume

      set(frame, stored + amount)

      amount
    end

    # Public: Returns how much of the reserve is unfilled.
    #
    # Returns a numeric.
    def unfilled_at(frame)
      @volume - at(frame)
    end

    # Public: Takes from the reserve the chosen `amount` of energy.
    #
    # Returns the amount of energy subtracted from the reserve. This may be less
    # than you asked for if insufficient was stored.
    def take(frame, amount)
      stored = at(frame)

      if stored > amount
        add(frame, -amount)
        amount
      else
        set(frame, 0.0)
        stored
      end
    end

    # Public: A human readable version of the reserve for debugging.
    def inspect
      "#<#{ self.class.name } volume=#{ @volume }>"
    end

    # Public: A human readable version of the reserve.
    def to_s
      "#{ self.class.name }(#{ @volume })"
    end

    # Internal: Returns how much energy decayed in the reserve at the beginning
    # of the given frame.
    #
    # Returns a numeric.
    private def decay_at(frame)
      return 0.0 if frame.zero? || ! @decay

      start = at(frame - 1)
      decay = @decay.call(frame, start)

      decay < start ? decay : start
    end
  end # Reserve
end
