class TestingGround::TechnologyDistributor
  #
  # Given a list of technologies, a topology
  # Creates a Hash with the technologies distributed over the nodes
  #

  def initialize(technologies, topology)
    @technologies = technologies.map{|t| InstalledTechnology.new(t) }
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
      partition.each_with_index.map do |tech, index|
        dup_technology = tech.dup
        dup_technology.node = edge_nodes[index + edge_nodes_index].key
        dup_technology
      end
    end
  end

  def edge_nodes_index
    less_buildings_than_nodes? ? households.units : 0
  end

  def less_buildings_than_nodes?
    is_building? && (@technology.units + households.units) < edge_nodes.size
  end

  def is_building?
    @technology.type == 'base_load_buildings'
  end

  def households
    @technologies.detect do |technology|
      technology.type == 'base_load'
    end
  end

  # Calculates the spread of units
  #
  # Returns an Array of Integers
  def partition
    TestingGround::TechnologyPartitioner.new(@technology, edge_nodes.size)
      .partition
  end
end
