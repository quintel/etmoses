module Calculation
  # Holds information about a graph, which is to be calcualted.
  class Context
    # Public: Returns the Turbine::Graph instance.
    attr_reader :graph

    # Public: Options which change the behavior of the calculation.
    attr_reader :options

    def initialize(graph, options = {})
      @graph   = graph
      @options = options
    end

    # Public: Determines which nodes in the graph have attached technologies.
    #
    # Returns an array of Network::Node instances.
    def technology_nodes
      @technology_nodes ||= graph.nodes.select do |node|
        node.get(:installed_techs).any?
      end
    end

    def paths
      @paths ||= Network::PathCollection.new(
        technology_nodes.map(&Network::TechnologyPath.method(:find)).flatten,
        path_order)
    end

    # Public: Determines how many time-steps are being calculated with this
    # testing ground.
    #
    # Returns an integer.
    def length
      @length ||= technology_nodes.map { |n| n.get(:installed_techs) }.flatten
        .map do |tech|
          tech.profile.present? ? tech.profile_curve.length : 1
        end.max || 1
    end

    # Public: Iterates through each frame in the testing ground graph. If no
    # block is given, an enumerable is returned.
    #
    # Returns an enumerable, or the result of the block.
    def frames
      if block_given?
        length.times.each { |frame| yield frame }
      else
        to_enum(:frames)
      end
    end

    #######
    private
    #######

    def path_order
      # TODO Solar PV and heat-pumps need to be added.
      [ Network::ElectricVehicle, Network::PreemptiveConsumer,
        Network::Battery, Network::Buffer, Network::Siphon ].map do |klass|
        ->(p) { p.technology.is_a?(klass) }
      end
    end
  end
end
