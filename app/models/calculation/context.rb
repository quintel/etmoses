module Calculation
  # Holds information about a graph, which is to be calcualted.
  class Context
    # Public: Options which change the behavior of the calculation.
    attr_reader :options

    def initialize(graphs, options = {})
      @graphs  = Hash[graphs.map { |g| [g.carrier, g] }]
      @options = options
    end

    # Public: Given the name of a carrier, returns the energy network used to
    # calculate the flows of that carrier.
    #
    # Returns a Network::Graph.
    # Raises a KeyError if no such network exists.
    def graph(carrier)
      @graphs.fetch(carrier)
    end

    # Public: All the networks being calculated, in an array.
    def graphs
      @graphs.values
    end

    # Public: Determines which nodes in the graph have attached technologies.
    #
    # Returns an array of Network::Node instances.
    def technology_nodes
      @technology_nodes ||= graphs.flat_map do |graph|
        graph.nodes.select do |node|
          node.get(:installed_techs).any? || node.techs.any? ||
            (node.get(:installed_comps) && node.get(:installed_comps).any?)
        end
      end
    end

    # Public: The top-most node in the electricity network.
    def head
      graph(:electricity).head
    end

    def paths
      @paths ||= Network::PathCollection.new(
        technology_nodes.flat_map { |node| Network::TechnologyPath.find(node) },
        [
          Network::PathCollection::ConstraintOrder,
          Network::PathCollection::TechnologyOrder.new(technology_order)
        ]
      )
    end

    # Public: An array containing all paths, and their subpaths, from each
    # technology to the head node. Subpaths describe each "step" from the
    # technology (and the node to which it belongs) and each parent node.
    #
    # Subpaths are sorted in a round-robin fashion so that loads can be assigned
    # more fairly (instead of the first node being given preference over the
    # others).
    #
    # TODO Extract into a PathCollection object so that we may call something
    #      like context.subpaths.each_level { ... }
    #
    # Returns an array of TechnologyPath instances.
    def subpaths
      @subpaths ||= begin
        by_level = Hash.new { |hash, key| hash[key] = [] }
        data     = {}

        paths.map(&:sub_paths).each do |subpaths|
          subpaths.each { |path| by_level[path.distance].push(path) }
        end

        # "Round-robin" paths of the same length, so as not to give preference
        # to technologies form the first node returned by "paths".
        by_level.each do |level, level_paths|
          by_parent = level_paths.group_by(&:leaf).values

          data[level] = Array.new(by_parent.map(&:length).max)
            .zip(*by_parent).flatten.compact
        end

        # Shortest subpaths first.
        data.keys.sort.reverse.map { |key| data[key] }
      end
    end

    # Public: Determines how many time-steps are being calculated with this
    # testing ground.
    #
    # Returns an integer.
    def length
      @length ||= begin
        techs = technology_nodes.flat_map do |node|
          (node.get(:installed_techs) || []) +
            (node.get(:installed_comps) || [])
        end

        techs.map do |t|
          t.profile_curve(@options[:range])
        end.map(&:length).max || 1
      end
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

    private

    # Describes the order in which paths are sorted, such that the technologies
    # are calculated in this order.
    #
    # Central heat producers come first since it is assumed that a heat
    # network -- if present -- will be used to satisfy heat demand before any
    # locally-installed technologies.
    #
    # HHP techs come next, since their mandatory consumption is instead
    # treated as conditional. This is so they are processed immediately after
    # the final mandatory consumption load is assigned.
    def technology_order
      @technology_order ||= [
        Network::Heat::Consumer,
        Network::Heat::Buffer,
        Network::Technologies::HHP::Electricity,
        Network::Technologies::HHP::Gas,
        Network::Technologies::OptionalConsumer,
        Network::Technologies::ConservingProducer,
        Network::Technologies::ElectricVehicle,
        Network::Technologies::Buffer,
        Network::Technologies::DeferrableConsumer,
        Network::Technologies::Battery,
        Network::Technologies::OptionalBuffer,
        :rest,
        Network::Technologies::Siphon
      ].freeze
    end
  end
end
