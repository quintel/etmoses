class TreeToGraph
  # Public: Creates a Turbine graph to represent the given hash structure.
  #
  # nodes - An array of nodes to be added to the graph. Each element in the
  #         array should have a unique :name key to identify the node, and an
  #         optional :children key containing an array of child nodes.
  # techs - A hash where each key matches the key of a node, and each value is
  #         an array of technologies connected to the node. Optional.
  #
  # For example:
  #
  #   nodes = YAML.load(<<-EOS.gsub(/  /, ''))
  #     ---
  #     name: HV Network
  #     children:
  #     - name: MV Network
  #       children:
  #       - name: "LV #1"
  #       - name: "LV #2"
  #       - name: "LV #3"
  #   EOS
  #
  #   ETLoader.build(structure)
  #   # => #<Turbine::Graph (5 nodes, 4 edges)>
  #
  # Returns a Turbine::Graph.
  def self.convert(tree, techs = {})
    new(tree, techs).to_graph
  end

  # Internal: Converts the tree and technologies into a Turbine::Graph.
  def to_graph
    @graph ||= build_graph
  end

  #######
  private
  #######

  def initialize(tree, techs)
    @tree  = tree
    @techs = techs
  end

  # Internal: Creates a new graph using the tree and technologies hash given to
  # the TreeToGraph.
  def build_graph
    graph  = Turbine::Graph.new
    source = graph.add(Turbine::Node.new(:source, transparent: true))

    build_node(@tree, source, graph)

    graph
  end

  # Internal: Builds a single node from the tree hash, and recurses through and
  # child nodes.
  def build_node(attrs, parent, graph = Turbine::Graph.new)
    attrs    = attrs.symbolize_keys
    children = attrs.delete(:children) || []
    node     = graph.add(Turbine::Node.new(attrs.delete(:name), attrs))

    # Parent connection.

    parent.connect_to(node, :energy)
    node.connect_to(parent, :energy, type: :overflow)

    # Consumers and suppliers.

    add_consumer_nodes(node, children, graph)
    add_supplier_nodes(node, children, graph)

    # Children

    children.each { |c| build_node(c, node, graph) }
  end

  # Internal: Converts consumption technologies attached to a node into an
  # explicit child node containing the sum of their demands.
  def add_consumer_nodes(node, children, graph)
    consumers = techs(node.key) { |t| t.key?(:demand) }

    if children.empty? && consumers.empty?
      # Nodes with no decendants need to have a "fake" consumer node to ensure
      # that the node can be calculated by refinery, without having to set the
      # demand explicitly to zero (which would prevent non-zero energy from
      # suppliers overflowing back to the parent).
      node.connect_to(
        graph.add(Turbine::Node.new(
          "#{ node.key } C", demand: 0.0, transparent: true
        )),
        :energy, demand: 0.0
      )
    elsif consumers.any?
      # Combine the demand of all the consumer technologies into one node.
      demand = consumers.reduce(0.0) { |sum, t| sum + t[:demand] }

      node.connect_to(
        graph.add(Turbine::Node.new(
          "#{ node.key } C", demand: demand, transparent: true
        )),
        :energy, child_share: 0.0, demand: demand
      )
    end
  end

  # Internal: Converts production technologies attached to a node into an
  # explicit parent node.
  def add_supplier_nodes(node, children, graph)
    suppliers = techs(node.key) { |t| t.key?(:capacity) }

    if suppliers.any?
      # Combine the production of all the supplier technologies into one node.
      production = suppliers.reduce(0.0) { |sum, t| sum + t[:capacity] }

      graph.add(
        Turbine::Node
          .new("#{ node.key } S", demand: production, transparent: true)
      ).connect_to(node, :energy, demand: production, parent_share: 1.0)
    end
  end

  # Internal: Returns an array of hashes, each one containing details of
  # technologies attached to the node. A block will yield each technology, and
  # only technologies for which the block returns true will be included in the
  # returned array.
  def techs(node_key)
    (@techs[node_key] || []).map(&:symbolize_keys).select { |tech| yield tech }
  end
end # TreeToGraph
