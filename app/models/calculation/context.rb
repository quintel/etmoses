module Calculation
  # Holds information about a graph, which is to be calcualted.
  class Context
    # Public: Returns the Turbine::Graph instance.
    attr_reader :graph

    def initialize(graph)
      @graph = graph
    end

    # Public: Determines which nodes in the graph have attached technologies.
    #
    # Returns an array of Network::Node instances.
    def technology_nodes
      @technology_nodes ||= graph.nodes.select do |node|
        node.get(:installed_techs).any?
      end
    end

    # Public: Determines how many time-steps are being calculated with this
    # testing ground.
    #
    # Returns an integer.
    def length
      @length ||= technology_nodes.map { |n| n.get(:installed_techs) }.flatten
        .map do |tech|
          tech.profile ? tech.profile_curve.length : 1
        end.max || 1
    end

    # Public: Iterates through each time-step point in the testing ground graph.
    # If no block is given, an enumerable is returned.
    #
    # Returns an enumerable, or the result of the block.
    def points
      if block_given?
        length.times.each { |point| yield point }
      else
        to_enum(:points)
      end
    end
  end
end
