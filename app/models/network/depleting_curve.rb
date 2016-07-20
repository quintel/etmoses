module Network
  # Represents a Curve whose values are reduced as loads are assigned to the
  # technology which owns the profile. Used by technologies which share a single
  # profile, where the demand may be met by one or more of the techs.
  class DepletingCurve < FastDelegator.create(Curve)
    def self.from(enumerable)
      if enumerable.is_a?(self)
        enumerable
      else
        new(Network::Curve.from(enumerable.to_a))
      end
    end

    def initialize(curve)
      super(Network::Curve.from(curve))
      @receipts = Network::DefaultArray.new { 0.0 }
    end

    # Public: Inform the curve that some or all of the demand has been
    # satisfied.
    #
    # Returns the total amount of demand which has been satisfied in the given
    # frame.
    def deplete(frame, amount)
      @receipts[frame] += amount
    end

    # Public: Returns the amount of load yet to be satisfied in the given frame.
    #
    # Returns a numeric.
    def get(frame)
      amount = super - @receipts[frame]

      # Ignore very small values which are likely the result of floating-point
      # rounding errors.
      amount > 1e-10 ? amount : 0.0
    end

    alias_method :at, :get
  end # DepletingCurve
end
