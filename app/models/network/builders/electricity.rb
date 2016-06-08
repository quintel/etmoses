require_relative '../builders'

module Network
  module Builders
    class Electricity
      # Public: Creates a Network graph to represent the given hash structure.
      #
      # nodes - An array of nodes to be added to the graph. Each element in the
      #         array should have a unique :name key to identify the node, and
      #         an optional :children key containing an array of child nodes.
      # techs - A hash where each key matches the key of a node, and each value
      #         is an array of technologies connected to the node. Optional.
      #
      # Returns a Network::Graph.
      def self.build(tree, techs = TechnologyList.new, *)
        new(tree, techs).to_graph
      end

      # Internal: Converts the tree and technologies into a Network::Graph.
      def to_graph
        @graph ||= build_graph
      end

      private

      def initialize(tree, techs)
        @tree  = tree || {}
        @techs = techs
      end

      # Internal: Creates a new graph using the tree and technologies hash given
      # to the TreeToGraph.
      def build_graph
        graph = Network::Graph.new(:electricity)
        build_node(@tree, graph, nil)
        graph
      end

      # Internal: Builds a single node from the tree hash, and recurses through
      # and child nodes.
      def build_node(attrs, graph, parent = nil)
        return unless valid_node?(attrs)

        attrs    = attrs.symbolize_keys
        children = attrs.delete(:children) || []
        node     = graph.add(Network::Node.new(attrs.delete(:name), attrs))

        composites, techs = @techs[node.key].partition(&:composite)

        node.set(:installed_comps, composites)
        node.set(:installed_techs, techs.select { |t| t.carrier != :gas })

        if node.get(:capacity) && node.get(:units)
          node.set(:capacity, node.get(:capacity) * node.get(:units))
        end

        parent.connect_to(node, :electricity) if parent
        children.each { |c| build_node(c, graph, node) }
      end

      # Internal: Determines if the given node attributes are sufficient to add
      # a new node to the graph.
      def valid_node?(attrs)
        attrs.key?(:name) || attrs.key?('name'.freeze)
      end
    end # Electricity
  end # Builders
end
