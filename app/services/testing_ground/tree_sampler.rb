class TestingGround
  module TreeSampler
    RESOLUTION_LENGTH_LOW = 365

    module_function

    def sample(networks, resolution = :high, nodes = nil)
      Hash[networks.map do |network|
        NetworkCache::LoadSetter.set(network, nodes) do |node|
          downsample(node.load.compact, resolution)
        end

        [network.carrier, GraphToTree.convert(network)]
      end]
    end

    def downsample(node_load, resolution)
      size = (node_load.length / RESOLUTION_LENGTH_LOW).floor

      if resolution.to_sym == :low && size > 0
        node_load.each_slice(size).map { |loads| loads.max_by(&:abs) }
      else
        node_load
      end
    end
  end
end
