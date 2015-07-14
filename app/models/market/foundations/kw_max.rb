module Market::Foundations
  # Partitions loads from the measurable into `paritions` groups, and extracts
  # the maximum load from each period. Default `paritions` is 12, which equates
  # to extracting the maximum load for each month.
  class KwMax
    def initialize(partitions = 12)
      @partitions = partitions
    end

    def call(node)
      loads = InstantaneousLoad.call(node)
      loads.each_slice(loads.length / @partitions).map(&:max)
    end
  end # KWMax
end # Market::Foundations
