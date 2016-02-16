class TestingGround
  class TreeSampler
    RESOLUTION_LENGTH_LOW = 365

    def self.sample(networks, resolution)
      Hash[networks.each_pair.map do |carrier, graph|
        graph.nodes.each do |node|
          node.set(:load, downsample(node.load, resolution))
        end

        [carrier, GraphToTree.convert(graph)]
      end]
    end

    def self.downsample(node_load, resolution)
      size = (node_load.length / RESOLUTION_LENGTH_LOW).floor

      if resolution.to_sym == :low && size > 0
        node_load.each_slice(size).map{ |loads| loads.max_by(&:abs) }
      else
        node_load
      end
    end
  end
end
