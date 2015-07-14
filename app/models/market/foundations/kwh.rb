module Market::Foundations
  # A sum of net consumption and production. Provide an optional "filter" block
  # which may alter each "energy" value as necessary.
  class Kwh
    def initialize(&filter)
      @filter = filter || -> amount { amount }
    end

    def call(node)
      InstantaneousLoad.call(node).length.times.sum do |frame|
        @filter.call(node.energy_at(frame))
      end
    end
  end
end # Market::Foundations
