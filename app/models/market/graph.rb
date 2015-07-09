module Market
  class Graph < Turbine::Graph
    def relations
      nodes.flat_map { |node| node.edges(:out).to_a }
    end
  end # Graph
end # Market
