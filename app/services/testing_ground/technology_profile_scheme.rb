class TestingGround::TechnologyProfileScheme
  #
  # Given a list of technologies, a topology and a differentiation setting
  # Creates a YAML with the maximum amount of selected profiles or minimum
  # amount of selected profiles
  #

  DEFAULT_CONCURRENY_SETTING = "max"

  def initialize(params)
    @technologies    = params[:technologies]
    @topology        = params[:topology]
    @differentiation = params[:profile_differentiation]
  end

  # Returns a hash with all edge nodes as keys and technologies as values
  def build
    Hash[transformed_technologies.each_with_index.map do |technologies, index|
      [edge_nodes[index].key, technologies]
    end]
  end

  private

    # Returns an array
    def edge_nodes
      @edge_nodes ||= Topologies::EdgeNodesFinder.new(@topology).find_edge_nodes
    end

    # Counts all unique units per technology edge node
    def transformed_technologies
      technology_spread.map do |techs|
        techs.compact.uniq{|t| "#{t['type']}_#{t['profile']}" }.map do |tech|
          tech['units'] = techs.count(tech)
          tech
        end
      end
    end

    # Divides the technologies evenly over each edge node
    # Returns a two-dimensional array of evenly distributed technologies
    def technology_spread
      technology_groups.inject([[]] * edge_nodes.size) do |spread, group|
        group.in_groups(edge_nodes.size).each_with_index do |tech_group, index|
          spread[index] += tech_group
        end
        spread
      end
    end

    # Groups technologies by type
    # Returns a two-dimensional array of technology groups
    def technology_groups
      profile_differentiation
        .group_by{|t| t['type'] }
        .values
    end

    # Sets a profile for each technology
    # Returns an array of technology-hashes with a profile assigned
    def profile_differentiation
      all_technologies.each_with_index.map do |technology,index|
        technology['profile'] = select_profile(technology['type'], index)
        technology
      end
    end

    # Duplicate all technologies according to the amount of units
    def all_technologies
      @technologies.inject([]) do |collection, technology|
        collection += (technology['units'] || 1).to_i.times.map do
          technology.dup
        end
      end
    end

    def select_profile(technology_type, index)
      profile_selector.select_profile(technology_type, index)
    end

    def profile_selector
      @profile_selector ||= Import::ProfileSelector.new(technology_keys, DEFAULT_CONCURRENY_SETTING)
    end

    def technology_keys
      @technologies.map{|t| t['type']}
    end
end
