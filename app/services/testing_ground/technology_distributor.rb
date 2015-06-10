class TestingGround::TechnologyDistributor
  #
  # Given a list of technologies, a topology
  # Creates a Hash with the technologies distributed over the nodes
  #

  def initialize(technologies, topology)
    @technologies = technologies
    @topology     = topology
  end

  # Returns an array with all technologies
  def build
    all_technologies.flatten
  end

  private

    # Returns an array
    def edge_nodes
      @edge_nodes ||= Topologies::EdgeNodesFinder.new(@topology).find_edge_nodes
    end

    # Duplicate all technologies according to the amount of units
    #
    # Returns a 2-dimensional Array of technologies and their 'node'
    def all_technologies
      @technologies.map do |technology|
        technology_units(technology).each_with_index.map do |tech, index|
          tech.dup.update('node' => edge_nodes[index].key)
        end
      end
    end

    # Calculates the spread of units
    #
    # Returns an Array of Integers
    def technology_units(technology)
      TestingGround::TechnologyPartitioner.new(technology, edge_nodes.size)
        .partition
    end
end
