class GraphToTree
  # Public: Given an acyclic Turbine graph, returns an array containing the
  # source nodes and their attributes, and recurses through the graph until all
  # child nodes are included.
  #
  # The resulting tree structure is used in the front-end to render the graph.
  #
  # Returns an Array.
  def self.convert(graph)
    convert_node(graph.nodes.detect { |n| n.in_edges.none? })
  end

  # Internal: Converts a single Turbine::Node an a hash of attributes.
  def self.convert_node(node)
    { name:     node.key,
      children: node.out_edges.map(&:to).to_a.map(&method(:convert_node)),
      capacity: node.get(:capacity),
      load:     node.get(:load).to_a }
  end

  private_class_method :convert_node
end # GraphToTree
