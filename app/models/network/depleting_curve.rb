module Network
  # Represents a Curve whose values are reduced as loads are assigned to the
  # technology which owns the profile. Used by technologies which share a single
  # profile, where the demand may be met by one or more of the techs.
  class DepletingCurve < SimpleDelegator
    def initialize(curve)
      super
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
      amount > 0 ? amount : 0.0
    end
  end # DepletingCurve
end
