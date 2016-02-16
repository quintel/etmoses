module Network
  # Describes an energy network.
  class Graph < Turbine::Graph
    attr_reader :carrier

    def initialize(carrier)
      super()
      @carrier = carrier
    end

    # Public: The top-most node in the network.
    def head
      @head ||= nodes.detect { |n| n.edges(:in).none? }
    end

    def set_loads(selected_nodes)
      keys = selected_nodes || nodes.map(&:key)

      keys.map{ |key| node(key) }.compact.each do |node|
        node.set(:load, yield(node))
      end
    end
  end # Graph
end
