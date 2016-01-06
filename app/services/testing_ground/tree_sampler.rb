class TestingGround
  class TreeSampler
    def initialize(networks)
      @networks = networks
    end

    def sample(resolution)
      Hash[@networks.each_pair.map do |carrier, graph|
        graph.nodes.each do |node|
          node.set(:load, downsample(node.load, resolution))
        end

        [carrier, GraphToTree.convert(graph)]
      end]
    end

    private

    def downsample(node_load, resolution)
      if resolution == :low
        node_load.each_slice(96).map do |loads|
          absolutes = loads.map(&:abs)

          loads[absolutes.index(absolutes.max)]
        end
      else
        node_load
      end
    end
  end
end
