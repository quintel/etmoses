module Market
  class PaymentRule
    # Public: Creates a new payment rule.
    #
    # foundation - A callable which will retrieve the value from the measurable
    #              objects. This should be an object responding to "call" and
    #              which accepts one or two arguments. If the foundation
    #              measures a year-round value, it should take one argument. If
    #              it needs to measure a separate value for each hour, the
    #              second argument is the frame to be computed.
    # tariff     - A numeric describing the price.
    #
    # Returns a PaymentRule.
    def initialize(foundation, tariff)
      @foundation = foundation
      @tariff     = tariff
    end

    # Public: Run the payment rule on a given relation.
    def call(relation)
      Array(value(relation)).sum(&@tariff.method(:price_of))
    end

    #######
    private
    #######

    def value(relation)
      relation.measurables.sum { |node| @foundation.call(node) }
    end
  end # PaymentRule
end # Market
