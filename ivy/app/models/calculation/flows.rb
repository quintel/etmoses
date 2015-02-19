module Calculation
  module Flows
    # Public: Calculates the load bottom-up.
    #
    # Starting with the leaf ("sink") nodes, the load of the graph is calculated
    # by summing the loads of any child nodes (including negative (supply)
    # loads) until we reach the top of the graph.
    #
    # This is done iteratively, with each calculated node returning an array of
    # parents which are added to the list to be calculated. If a a node being
    # calculated has one or more children which have not yet themselves been
    # calculated, the node will be skipped and returned to later.
    #
    # Returns the graph.
    def self.call(graph, point)
      visited = {}
      nodes   = graph.nodes.reject { |n| n.out_edges.any? }

      # Every leaf node should have a load by now. If it doesn't, set the load
      # to zero.
      nodes.each { |node| node.set(:load, 0.0) unless node.get(:load) }

      while node = nodes.shift
        next if visited.key?(node)

        if node.out.get(:load).any?(&:nil?)
          # One or more children haven't yet got a load.
          nodes.push(node)
          next
        end

        calculate_node(node, point)
        nodes.push(*node.in.to_a)

        visited[node] = true
      end

      graph
    end

    # Internal: Computed the load of a single node.
    #
    # Returns the calculated demand, or nil if the node had already been
    # calculated.
    def self.calculate_node(node, point)
      return if node.get(:load)

      node.set(:load, node.out_edges.map do |edge|
        edge.set(:load, edge.to.get(:load))
      end.reduce(:+))
    end
  end # Flows
end # Calculation
