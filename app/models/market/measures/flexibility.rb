module Market::Measures
  # A measure which descibes the difference between the focus network, and the
  # "basic" network (minus all storage and load management features).
  class Flexibility
    def initialize(&filter)
      @filter = filter || -> (amount, *) { amount }
    end

    def call(node, variants)
      variant = variants[:basic].call

      InstantaneousLoad.call(node).length.times.map do |frame|
        feature = node.energy_at(frame)
        basic   = variant.energy_at(frame)

        @filter.call(flexibility(feature, basic), node)
      end
    end

    private

    def flexibility(feature, basic)
      # abs because a swing from -2 to 2 isn't flexibility; the load is the same
      # but in the opposite direction. A swing from -3 to 2 is a "flexibility"
      # increase of 1.
      diff = basic.abs - feature.abs
      diff < 0 ? 0.0 : diff
    end
  end
end
