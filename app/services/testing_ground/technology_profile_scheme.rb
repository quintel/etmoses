class TestingGround::TechnologyProfileScheme
  #
  # Given a distributed set of technologies and a differentiation setting
  # Creates a Hash with the maximum amount of selected profiles or minimum
  # amount of selected profiles
  #

  def initialize(distribution)
    @distribution = distribution
  end

  # Returns a hash with all edge nodes as keys and technologies as values
  def build
    technology_profile_scheme.group_by do |technology|
      technology['node']
    end
  end

  private

  #
  # Removes duplicates when going from a minimum concurrency to a maximum
  #
  def technology_profile_scheme
    grouped_profiles.values.map do |techs|
      techs.first.update('units' => techs.sum{|b| b['units'].to_i })
    end
  end

  def grouped_profiles
    assigned_profiles.group_by do |tech|
      [tech['node'], tech['profile']].join
    end
  end

  def assigned_profiles
    expanded_distribution.flatten.map do |tech|
      tech.dup.update('profile' => profile_selector(tech).select_profile)
    end
  end

  #
  # Expands the technology distribution depending on a technology's
  # concurrency setting and amount of profiles
  #
  def expanded_distribution
    @distribution.map do |technology|
      TestingGround::TechnologyPartitioner.new(
        technology, profile_selector(technology).size
      ).partition
    end
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
