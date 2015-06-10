class TestingGround::TechnologyProfileScheme
  #
  # Given a distributed set of technologies and a differentiation setting
  # Creates a Hash with the maximum amount of selected profiles or minimum
  # amount of selected profiles
  #

  def initialize(technology_distribution, max_concurrency = true)
    @technology_distribution = technology_distribution
    @max_concurrency         = max_concurrency
  end

  # Returns a hash with all edge nodes as keys and technologies as values
  def build
    technology_profile_scheme.group_by do |technology|
      technology['node']
    end
  end

  private

    def technology_profile_scheme
      grouped_profiles.values.map do |techs|
        techs.first.update('units' => techs.sum{|b| b['units']})
      end
    end

    def grouped_profiles
      assigned_profiles.group_by do |tech|
        [tech['node'], tech['profile']].join
      end
    end

    def assigned_profiles
      expanded_distribution.flatten.map do |tech|
        tech.dup.update('profile' => profile_selector.select(tech['type']))
      end
    end

    def profile_selector
      @profile_selector ||= Import::ProfileSelector.new(technology_keys, @max_concurrency)
    end

    def technology_keys
      @technology_distribution.map{|t| t['type']}.uniq
    end

    def expanded_distribution
      @technology_distribution.map do |tech|
        TestingGround::TechnologyPartitioner.new(tech,
          profile_selector.profiles_size(tech['type'])
        ).partition
      end
    end
end
