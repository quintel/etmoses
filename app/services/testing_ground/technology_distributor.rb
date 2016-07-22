class TestingGround
  class TechnologyDistributor
    include ProfileSelector
    include BufferCreator
    include Updater

    #
    # Given a list of technologies, a topology
    # Creates a Hash with the technologies distributed over the nodes
    #

    def initialize(technologies, topology)
      @technologies   = technologies.map { |tech| InstalledTechnology.new(tech) }
      @topology       = topology
      @buffer_counter = BufferCounter.new
    end

    # Returns an array with all technologies
    def build
      partitioned.flat_map do |technologies|
        technologies.each_with_index.map do |technology, index|
          update_technology(technology, index)
        end
      end
    end

    private

    def partitioned
      @technologies.reject(&:composite).map(&method(:partition))
    end

    # Calculates the spread of units
    #
    # Returns an Array of Integers
    def partition(technology)
      TechnologyPartitioner.new(technology, edge_nodes.size).partition
    end

    def edge_nodes
      Topologies::EdgeNodesFinder.new(@topology).find_edge_nodes
    end
  end
end
