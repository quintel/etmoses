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

      @arity =
        if foundation.respond_to?(:arity)
          foundation.arity
        else
          foundation.method(:call).arity
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
          @foundation.call(measurable, variants_for(measurable, variants))
        else
          @foundation.call(measurable)
        end
      end
    end

    def variants_for(measurable, variants)
      Hash[variants.map { |name, variant| [name, variant.call(measurable)] }]
    end
  end # PaymentRule
end # Market
