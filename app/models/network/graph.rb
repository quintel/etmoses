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
  end # Graph
end
