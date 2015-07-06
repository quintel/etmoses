module Market
  # A wrapper around a foundation which will divide the value computed by the
  # foundation by a "number of units".
  class PerUnitFoundation
    # Public: Creates a new PerUnitFoundation.
    #
    # base     - The normal foundation which pays no respect to number of units.
    # to_units - A proc which, given each measurable, determines how many units
    #            there are.
    #
    # Returns a per-unit foundation.
    def initialize(base, to_units)
      @base = base
      @to_units = to_units
    end

    def arity
      @base.arity
    end

    def call(measurable, *rest)
      @base.call(measurable, *rest) / @to_units.call(measurable)
    end

    #######
    private
    #######

    def units(measurable)
      @to_units.call(measurable)
    end
  end # PerUnitFoundation
end # Market
