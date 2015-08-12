module Market
  # A wrapper around a measure which will divide the value computed by the
  # measure by a "number of units".
  class PerUnitMeasure
    # Public: Creates a new PerUnitMeasure.
    #
    # base     - The normal measure which pays no respect to number of units.
    # to_units - A proc which, given each measurable, determines how many units
    #            there are.
    #
    # Returns a per-unit measure.
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
  end
end
