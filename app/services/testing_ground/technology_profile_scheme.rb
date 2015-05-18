class TestingGround::TechnologyProfileScheme
  #
  # Given a list of technologies, a topology and a differentiation setting
  # Creates a YAML with the maximum amount of selected profiles or minimum
  # amount of selected profiles
  #

  def initialize(technologies, topology, differentiation = "max")
    @technologies    = technologies
    @topology        = topology
    @differentiation = differentiation
  end

  # Returns a hash with all edge nodes as keys and technologies as values
  def build
    Hash[all_technologies.each_with_index.map do |technologies, index|
      [edge_nodes[index].key, technologies]
    end]
  end

  private

    # Returns an array
    def edge_nodes
      @edge_nodes ||= Topologies::EdgeNodesFinder.new(@topology).find_edge_nodes
    end

    # Duplicate all technologies according to the amount of units
    # Also assigns the profiles
    #
    # Returns a 2-dimensional Array of technologies per 'node'
    def all_technologies
      @technologies.map do |technology|
        technology_units(technology).each_with_index do |unit, index|
          technology_bucket[index % edge_nodes.size] += [
            duplicate_technology(technology, unit, index)
          ]
        end
      end
      technology_bucket
    end

    def duplicate_technology(tech, unit, index)
      duplicate_technology            = tech.dup
      duplicate_technology['units']   = unit
      duplicate_technology['profile'] = select_profile(tech['type'], index)
      duplicate_technology
    end

    def technology_bucket
      @technology_bucket ||= [[]] * edge_nodes.size
    end

    # Calculates the spread of units
    #
    # Returns an Array of Integers
    def technology_units(technology)
      group_size = group_size_for(technology['type'])
      div, mod   = technology['units'].to_i.divmod(group_size)

      (Array.new(mod, div + 1) +
       Array.new(group_size - mod, div)).reject do |unit|
        unit.zero?
      end
    end

    def group_size_for(tech_key)
      profile_selector.profiles_size(tech_key) * edge_nodes.size
    end

    def select_profile(technology_type, index)
      profile_selector.select_profile(technology_type, index)
    end

    def profile_selector
      @profile_selector ||= Import::ProfileSelector.new(technology_keys, @differentiation)
    end

    def technology_keys
      @technologies.map{|t| t['type']}.uniq
    end
end
