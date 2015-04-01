class Import
  # Given an array of technology keys which are to be imported from an ETEngine
  # scenario, retrieves the load profiles which may be used by those
  # technologies.
  #
  # Calling +for_tech+ will return an Enumerator which may be used to fairly
  # assign profiles in a round-robin fashion.
  class ProfileSelector
    # Public: Creates a ProfileSelector which selects profiles for the given
    # +technologies+ keys.
    def initialize(technologies)
      @technologies = technologies
    end

    # Public: Given a technology key, retrieves an infinite-length Enumerator
    # which will select profiles which may be used with the technology.
    def for_tech(technology)
      Enumerator.new do |yielder|
        tech_profiles = (profiles[technology] || []).dup

        loop do
          element = tech_profiles.shift
          tech_profiles.push(element)

          yielder.yield(element)
        end
      end
    end

    #######
    private
    #######

    # Internal: A hash containing all of the technology keys and their permitted
    # profiles.
    def profiles
      @profiles ||= begin
        permits = TechnologyProfile
          .where(technology: @technologies)
          .includes(:load_profile)

        Hash[permits.group_by(&:technology).map do |tech_key, techs|
          [tech_key, techs.map { |tech| tech.load_profile.key }]
        end]
      end
    end
  end
end
