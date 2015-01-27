# Takes a Refinery graph and computes loads.
module Calculator
  module_function

  # Public: Given a graph, calculated the load bottom-up.
  #
  # Starting with the leaf ("sink") nodes, the load of the graph is calculated
  # by summing the loads of any child nodes (including negative (supply) loads)
  # until we reach the top of the graph.
  #
  # This is done iteratively, with each calculated node returning an array of
  # parents which are added to the list to be calculated. If a a node being
  # calculated has one or more children which have not yet themselves been
  # calculated, the node will be skipped and returned to later.
  #
  # Returns the given graph.
  def calculate(graph)
    nodes = graph.nodes.reject { |n| n.out_edges.any? }

    while node = nodes.shift
      if node.out.get(:load).any?(&:nil?)
        # One or more children haven't yet got a load.
        nodes.push(node)
        next
      end

      calculate_node(node)

      nodes.push(*node.in.to_a)
    end

    graph
  end

  # Internal: Computed the load of a single node.
  #
  # Returns nothing.
  def calculate_node(node)
    return if node.get(:load)

    node.set(:load, node.out_edges.map do |edge|
      edge.set(:load, edge.to.get(:load))
    end.reduce(:+))
  end
end # Calculator
