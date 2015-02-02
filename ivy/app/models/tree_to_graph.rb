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
    @tree  = tree || {}
    @techs = techs
  end

  # Internal: Creates a new graph using the tree and technologies hash given to
  # the TreeToGraph.
  def build_graph
    graph = Turbine::Graph.new
    build_node(@tree, nil, graph)
    graph
  end

  # Internal: Builds a single node from the tree hash, and recurses through and
  # child nodes.
  def build_node(attrs, parent = nil, graph = Turbine::Graph.new)
    return unless valid_node?(attrs)

    attrs    = attrs.symbolize_keys
    children = attrs.delete(:children) || []
    node     = graph.add(Turbine::Node.new(attrs.delete(:name), attrs))

    # Parent connection.

    parent.connect_to(node, :energy) if parent

    # Consumers and suppliers.

    if (techs = techs(node.key)).any?
      node.set(:load, techs.map do |tech|
        Rational((tech[:load] || 0.0).to_s)
      end.compact.reduce(:+))
    elsif children.none?
      node.set(:load, Rational('0.0'))
    end

    # Children

    children.each { |c| build_node(c, node, graph) }
  end

  # Internal: Returns an array of hashes, each one containing details of
  # technologies attached to the node.
  def techs(node_key)
    (@techs[node_key] || []).map(&:symbolize_keys)
  end

  # Internal: Determines if the given node attributes are sufficient to add a
  # new node to the graph.
  def valid_node?(attrs)
    attrs.key?(:name) || attrs.key?('name'.freeze)
  end
end # TreeToGraph
