module Calculation
  module Flows
    module_function

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
    def call(graph)
      leaves = graph.nodes.reject { |n| n.edges(:out).any? }
      length = leaves.map { |n| n.get(:load).try(:length) || 1 }.max

      # Every leaf node should have a load by now. If it doesn't, set the load
      # to zero.
      leaves.select { |n| n.get(:techs).empty? }.each do |node|
        node.set(:load, Array.new(length, 0.0))
      end

      # Calculate once to determine the optimum order to calculate the nodes.
      calculate_load(leaves, 0)

      # Now we know in which order the nodes were calculated, we can use the
      # same order for each subsequent point, and gain a nice performance boost
      # from not having to shift/try/push onto a stack.
      ordered_nodes = graph.nodes.sort_by { |n| n.get(:order) }

      (length - 1).times do |point|
        ordered_nodes.each { |node| calculate_node(node, point + 1) }
      end

      graph
    end

    # Internal: Completely calculates a single point, without optimisations.
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
    # An :order attribute is set on each node indicating in which order they
    # were successfully calculated. Subsequent points can thus be calculated in
    # this order without the need to shift/try/pop nodes onto a stack on a
    # trial-and-error basis.
    #
    # Returns nothing.
    def calculate_load(leaves, point)
      visited = {}

      nodes = leaves.dup
      order = -1

      while node = nodes.shift
        next if visited.key?(node)

        if node.nodes(:out).map { |n| n.load_at(point) }.any?(&:nil?)
          # One or more children haven't yet got a load.
          nodes.push(node)
          next
        end

        calculate_node(node, point)
        node.set(:order, order += 1)

        nodes.push(*node.in.to_a)

        visited[node] = true
      end
    end

    # Internal: Computed the load of a single node.
    #
    # Returns the calculated demand, or nil if the node had already been
    # calculated.
    def calculate_node(node, point)
      unless node.load_at(point)
        node.set_load(point, node.edges(:out).sum do |edge|
          edge.to.load_at(point)
        end)
      end
    end
  end # Flows
end # Calculation
