class TestingGround
  class TechnologyProfileScheme
    #
    # Given a distributed set of technologies and a differentiation setting
    # Creates a Hash with the maximum amount of selected profiles or minimum
    # amount of selected profiles
    #

    def initialize(distribution)
      @distribution = distribution.map do |technology|
        InstalledTechnology.new(technology)
      end
    end

    # Returns a hash with all edge nodes as keys and technologies as values
    def build
      Hash[technology_profile_scheme.group_by(&:node).map do |node, technologies|
        [node, technologies.map { |tech| tech.attributes.stringify_keys } ]
      end]
    end

    private

    #
    # Removes duplicates when going from a minimum concurrency to a maximum
    def technology_profile_scheme
      grouped_profiles.values.map do |techs|
        tech = techs.first
        tech.units = techs.sum(&:units)
        tech
      end
    end

    def grouped_profiles
      assigned_profiles.to_a.flatten.group_by do |tech|
        [tech.node, tech.buffer, tech.profile, tech.type].join
      end
    end

    def assigned_profiles
      Hash[inflate_children.map do |parent, children|
        [parent_with_profile(parent), children]
      end]
    end

    def parent_with_profile(technology)
      technology = technology.dup
      technology.profile = profile_selector(technology).select_profile
      technology
    end

    # Duplicate all children for parents
    def inflate_children
      expanded_distribution.inject({}) do |hash, parents|
        parents.each_with_index.map do |parent, index|
          hash[parent] = parent.associates
        end
        hash
      end
    end

    #
    # Expands the technology distribution depending on a technology's
    # concurrency setting and amount of profiles
    #
    def expanded_distribution
      connected_distribution.map do |tech|
        TechnologyPartitioner.new(tech, profile_selector(tech).size).partition
      end
    end

    def connected_distribution
      TechnologyConnector.new(@distribution).connect
    end

    #
    # Profile selection part
    # Initiates a Profile::Selector object
    #
    def profile_selector(technology)
      LoadProfiles::Selector.new(available_profiles, technology)
    end

    def available_profiles
      @available_profiles ||= TechnologyProfiles::Query.new(@distribution).query
    end
  end
end
