class Import
  # Given an array of technology keys which are to be imported from an ETEngine
  # scenario, retrieves the load profiles which may be used by those
  # technologies.
  #
  class ProfileSelector
    # Public: Creates a ProfileSelector which selects profiles for the given
    # +technologies+ keys.
    def initialize(technologies, max_concurrency)
      @technologies = technologies
      @max_concurrency = max_concurrency
    end

    def profiles_size(technology_type)
      if !@max_concurrency && profiles[technology_type]
        profiles[technology_type].size
      else
        1
      end
    end

    def select(technology)
      if @max_concurrency
        first(technology)
      else
        for_tech(technology).next
      end
    end

    private

      def for_tech(technology)
        Enumerator.new do |yielder|
          tech_profiles = (profiles[technology] || [])

          loop do
            element = tech_profiles.shift
            tech_profiles.push(element)

            yielder.yield(element)
          end
        end
      end

      def first(technology)
        profiles[technology].try(:first)
      end

      # Creates a hash of technologies associated with the load profile keys
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
