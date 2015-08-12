module Market
  class PaymentRule
    # Public: Creates a new payment rule.
    #
    # measure - A callable which will retrieve the value from the measurable
    #           objects. This should be an object responding to "call" and
    #           which accepts one or two arguments. If the measure returns a
    #           year-round value, it should take one argument. If it needs to
    #           measure a separate value for each hour, the second argument is
    #           the frame to be computed.
    # tariff  - A numeric describing the price.
    #
    # Returns a PaymentRule.
    def initialize(measure, tariff)
      @measure = measure
      @tariff  = tariff

      @arity =
        if measure.respond_to?(:arity)
          measure.arity
        else
          measure.method(:call).arity
        end
    end

    # Public: Run the payment rule on a given relation.
    def call(relation, variants = {})
      Array(value(relation, variants)).sum(&@tariff.method(:price_of))
    end

    #######
    private
    #######

    def value(relation, variants)
      relation.measurables.sum do |measurable|
        if @arity > 1
          @measure.call(measurable, variants_for(measurable, variants))
        else
          @measure.call(measurable)
        end
      end
    end

    def variants_for(measurable, variants)
      Hash[variants.map { |name, variant| [name, variant.call(measurable)] }]
    end
  end # PaymentRule
end # Market
