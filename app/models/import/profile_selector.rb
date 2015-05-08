class Import
  # Given an array of technology keys which are to be imported from an ETEngine
  # scenario, retrieves the load profiles which may be used by those
  # technologies.
  #
  class ProfileSelector
    # Public: Creates a ProfileSelector which selects profiles for the given
    # +technologies+ keys.
    def initialize(technologies, differentiation)
      @technologies = technologies
      @differentiation = differentiation
    end

    # Minimal differentiation
    # Selects the first profile for a certain technology
    #
    # Maximum differentiation
    # Selects a profile from a list of profiles according to an index
    def select_profile(technology_type, index)
      if available_profiles = profiles[technology_type]
        if @differentiation == "max"
          available_profiles.first
        elsif profiles.any?
          available_profiles[index % available_profiles.length]
        end
      end
    end

    private

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
