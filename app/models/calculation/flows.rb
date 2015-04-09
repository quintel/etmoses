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
    def call(context)
      source = context.graph.nodes.detect { |node| node.edges(:in).none? }
      context.points { |point| source.load_at(point) }

      context
    end
  end # Flows
end # Calculation
