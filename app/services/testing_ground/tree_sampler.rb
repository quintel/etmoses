class TestingGround
  module TreeSampler
    # The number of samples per day in a high-resolution curve.
    DAY_CHUNK_SIZE = 96

    module_function

    def sample(networks, resolution = :high, nodes = nil)
      Hash[networks.map do |network|
        NetworkCache::LoadSetter.set(network, nodes) do |node|
          downsample(node.load.compact, resolution)
        end

        [network.carrier, GraphToTree.convert(network)]
      end]
    end

    def downsample(loads, resolution)
      return loads if resolution != :low || loads.length.zero?

      loads.each_slice(DAY_CHUNK_SIZE).map do |chunk|
        # Tech loads may be nil when the technology load had no frame.
        # Therefore, the nils are removed from the chunk before determining the
        # peak load.
        chunk.compact.max_by(&:abs)
      end
    end
  end
end
