require_relative '../builders'

module Network
  module Builders
    # Given a topology tree and technologies used in a testing ground,
    # constructs a gas network consisting of endpoints which have one or more
    # gas technologies, attached a shared, parent node "Gas Network".
    class Gas
      def self.build(tree, techs = TechnologyList.new, *)
        new(tree, techs).to_graph
      end

      def to_graph
        @graph || build_graph
      end

      private

      def initialize(tree, techs)
        @tree  = tree
        @techs = techs
      end

      def build_graph
        @graph = Graph.new(:gas)
        @head  = @graph.add(Node.new('Gas Network', installed_techs: []))

        build_node(@tree, nil)

        @graph
      end

      def build_node(attrs, parent = nil)
        attrs    = attrs.symbolize_keys
        children = attrs.delete(:children) || []

        return unless valid_node?(attrs)

        if children.any?
          children.each { |child| build_node(child) }
        else
          name  = attrs.delete(:name)
          techs = @techs[name].select { |t| t.carrier == :gas }

          # Workaround for the lack of multi-carrier support in technologies;
          # P2P siphons electricity and emits it as production on the gas
          # network.
          delegates = @techs[name].select { |t| t.behavior == 'siphon'.freeze }

          return if techs.empty? && delegates.empty?

          @head.connect_to(@graph.add(
            Node.new(name, {
              installed_techs: techs,
              installed_comps: []
            })
          ))
        end
      end

      # Internal: Determines if the given node attributes are sufficient to add a
      # new node to the graph.
      def valid_node?(attrs)
        attrs.key?(:name) || attrs.key?('name'.freeze)
      end
    end # Gas
  end # Builders
end
