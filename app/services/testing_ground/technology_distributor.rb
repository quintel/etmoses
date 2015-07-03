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
        @technology = technology
        technology_units.each_with_index.map do |tech, index|
          tech.dup.update({'node' => edge_nodes[edge_nodes_index(index)].key,
                           'concurrency' => 'max' })
        end
      end
    end

    def edge_nodes_index(index)
      less_buildings_than_nodes? ? index + households['units'] : index
    end

    def less_buildings_than_nodes?
      is_building? && (@technology['units'] + households['units']) < edge_nodes.size
    end

    def is_building?
      @technology['type'] == 'base_load_buildings'
    end

    def households
      @technologies.detect{|t| t['type'] == 'base_load' }
    end

    # Calculates the spread of units
    #
    # Returns an Array of Integers
    def technology_units
      TestingGround::TechnologyPartitioner.new(@technology, edge_nodes.size)
        .partition
    end
end
