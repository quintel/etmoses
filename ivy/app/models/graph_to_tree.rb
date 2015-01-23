class GraphToTree
  # Public: Given an acyclic Turbine graph, returns an array containing the
  # source nodes and their attributes, and recurses through the graph until all
  # child nodes are included.
  #
  # The resulting tree structure is used in the front-end to render the graph.
  #
  # Returns an Array.
  def self.convert(graph)
    [convert_node(graph.node(:source).out.first)]
  end

  # Internal: Converts a single Turbine::Node an a hash of attributes.
  def self.convert_node(node)
    children = node.out_edges
      .reject { |e| e.get(:type) == :overflow || e.to.get(:transparent) }
      .map(&:to).to_a.map(&method(:convert_node))

    props = node.properties.except(:technologies).merge(
      name:     node.key,
      children: children
    )

    if props[:demand]
      props[:demand] = props[:demand].to_f
    end

    props
  end

  private_class_method :convert_node
end # GraphToTree
