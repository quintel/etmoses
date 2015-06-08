class TestingGround::TechnologyProfileScheme
  #
  # Given a list of technologies, a topology and a differentiation setting
  # Creates a Hash with the maximum amount of selected profiles or minimum
  # amount of selected profiles
  #

  def initialize(technologies, topology, max_concurrency = true)
    @technologies    = technologies
    @topology        = topology
    @max_concurrency = max_concurrency
  end

  # Returns a hash with all edge nodes as keys and technologies as values
  def build
    assigned_profiles.group_by do |technology|
      technology['node']
    end
  end

  private

    def assigned_profiles
      expanded_distribution.flatten.map do |technology|
        technology.dup.update(
          'profile' => profile_selector.select(technology['type'])
        )
      end
    end

    def profile_selector
      @profile_selector ||= Import::ProfileSelector.new(technology_keys, @max_concurrency)
    end

    def technology_keys
      @technologies.map{|t| t['type']}.uniq
    end

    def expanded_distribution
      technology_distribution.map do |tech|
        TestingGround::TechnologyPartitioner.new(tech,
          profile_selector.profiles_size(tech['type'])
        ).partition
      end
    end

    def technology_distribution
      @technology_distribution ||= TestingGround::TechnologyDistributor.new(
                                     @technologies, @topology).build
    end
end
