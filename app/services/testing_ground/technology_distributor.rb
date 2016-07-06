class TestingGround
  class TechnologyDistributor
    include Concurrency::ProfileSelector

    #
    # Given a list of technologies, a topology
    # Creates a Hash with the technologies distributed over the nodes
    #

    def initialize(technologies, topology)
      @technologies = technologies.map { |tech| InstalledTechnology.new(tech) }
      @topology     = topology
    end

    # Returns an array with all technologies
    def build
      TechnologyConnector.connect(@technologies).flat_map do |technology|
        @technology = technology

        partition.each_with_index.map(&method(:update_tech))
      end
    end

    private

    # Returns an array
    def edge_nodes
      @edge_nodes ||= begin
        node_keys = @technologies.map(&:node).compact

        topology_edge_nodes.select do |node|
          node_keys.include?(node.key) || node_keys.empty?
        end
      end
    end

    def topology_edge_nodes
      Topologies::EdgeNodesFinder.new(@topology).find_edge_nodes
    end

    def update_tech(tech, index)
      dup_technology         = tech.dup
      dup_technology.profile = profile_selector(dup_technology).select_profile
      dup_technology.node    = edge_nodes[index + edge_nodes_index].key
      dup_technology
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
      TechnologyPartitioner.new(@technology, edge_nodes.size).partition
    end
  end
end
