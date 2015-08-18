module Market
  # Represets a tariff whose price varies throughout the year.
  class CurveTariff
    # Public: Creates a new CurveTariff with the given Network::Curve.
    def initialize(curve)
      fail InvalidCurveError, curve unless curve.is_a?(Network::Curve)
      @curve = curve
    end

    def price_of(units)
      units = Array(units)

      if units.length != @curve.length
        fail CurveLengthError.new(@curve.length, units.length)
      end

      (@curve * units).to_a.sum
    end
  end
end
