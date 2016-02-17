class TestingGround
  class TechnologyDistributor
    #
    # Given a list of technologies, a topology
    # Creates a Hash with the technologies distributed over the nodes
    #

    def initialize(technologies, topology)
      @technologies = set_technologies(technologies)
      @topology     = topology
    end

    # Returns an array with all technologies
    def build
      all_technologies.flatten
    end

    private

    def set_technologies(technologies)
      technologies.map do |t|
        InstalledTechnology.new(t)
      end
    end

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

    # Duplicate all technologies according to the amount of units
    #
    # Returns a 2-dimensional Array of technologies and their 'node'
    def all_technologies
      @technologies.map do |technology|
        @technology = technology

        partition.each_with_index.map(&method(:duplicate_technology))
      end
    end

    def duplicate_technology(tech, index)
      dup_technology = tech.dup
      dup_technology.composite_index = (index + 1)

      if dup_technology.composite
        dup_technology.composite_value = dup_technology.get_composite_value
        dup_technology.name            = dup_technology.get_composite_name
      elsif buffer = associations[dup_technology.type]
        dup_technology.buffer = dup_technology.get_buffer(buffer)
      end

      dup_technology.node ||= edge_nodes[index + edge_nodes_index].key
      dup_technology
    end

    def associations
      @technologies.select(&:composite).each_with_object({}) do |composite, result|
        composite.includes.map do |inc|
          result[inc] = composite.type
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
      TechnologyPartitioner.new(@technology, edge_nodes.size).partition
    end
  end
end
