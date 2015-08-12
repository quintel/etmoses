module Market
  # Represents a source of "alternative" versions of a measurable.
  #
  # A typical example is that you want to run the market model on a "feature"
  # network which includes storage or load management, but you also need a copy
  # of the "basic" network which has these features disabled. In this situation,
  # you define a Variant which sets up the basic network, and any measure which
  # requires values from the basic network will trigger the calculation.
  class Variant
    def initialize(&realiser)
      @realiser = realiser
    end

    def call(measurable)
      -> { get(measurable) }
    end

    private

    def get(node)
      object.node(node.key)
    end

    def object
      @object ||= @realiser.call
    end
  end
end
