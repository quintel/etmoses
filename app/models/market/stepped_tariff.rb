module Market
  class SteppedTariff
    # Internal: Stores threshold ranges and their prices.
    Step = Struct.new(:range, :price)

    # Public: Creates a new SteppedTariff which increases in steps as each
    # threshold value is reached.
    #
    # steps - An array of arrays, with each sub-array being in the form:
    #         [threshold, price]. Threshold indicates the lowest value at which
    #         the price begins to apply.
    #
    # For example
    #
    #   tariff = SteppedTariff(10.0, [[2, 12.0], [4, 14.0]])
    #
    #   tariff.price_of(1) # => 10.0
    #   tariff.price_of(2) # => 12.0
    #   tariff.price_of(3) # => 12.0
    #   tariff.price_of(4) # => 14.0
    #
    # Returns a SteppedTariff.
    def initialize(lowest, steps = [])
      steps = [[-Float::INFINITY, lowest], *steps]

      if steps.length == 1
        @steps = [Step.new(-Float::INFINITY..Float::INFINITY, lowest)]
      else
        @steps = build_steps(steps)
      end
    end

    # Public: Given a number of units, returned by a foundation, determines the
    # approprite price.
    #
    # Returns a numeric.
    def price_of(units)
      @steps.detect { |step| step.range.include?(units) }.price
    end

    #######
    private
    #######

    def build_steps(steps)
      # Start with the lowest step which runs from minus infinity to the first
      # step value given by the user.
      built = steps.each_cons(2).map do |lower, higher|
        Step.new((lower.first)...(higher.first), lower.last)
      end

      # Add the final step which runs from the highest step to infinity.
      built.push(
        Step.new((steps.last.first)..Float::INFINITY, steps.last.last))

      built
    end
  end # SteppedTariff
end # Market
