class GraphToTree
  # Public: Given an acyclic Turbine graph, returns an array containing the
  # source nodes and their attributes, and recurses through the graph until all
  # child nodes are included.
  #
  # The resulting tree structure is used in the front-end to render the graph.
  #
  # Returns an Array.
  def self.convert(graph)
    graph.nodes
      .select { |n| n.in.to_a.empty? }
      .map(&method(:convert_node))
  end

  # Internal: Converts a single Turbine::Node an a hash of attributes.
  def self.convert_node(node)
    node.properties.except(:technologies).merge(
      name:     node.key,
      children: node.out.map(&method(:convert_node)).to_a
    )
  end

  private_class_method :convert_node
end # GraphToTree
