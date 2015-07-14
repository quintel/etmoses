module Market::Foundations
  # A foundation which descibes the difference between the focus network, and
  # the "basic" network (minus all storage and load management features).
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
      difference = basic - feature
      difference > 0 ? difference : 0.0
    end
  end
end # Market::Foundations
