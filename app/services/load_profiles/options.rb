module LoadProfiles
  class Options
    #
    # Class to generate options for load profiles
    #
    def initialize(load_profiles, technology_profile, technology)
      @load_profiles  = selected_load_profiles(load_profiles, technology)
      @technology_profile = technology_profile
    end

    def generate_options
      if selected_profiles.any?(&:deprecated?)
        @load_profiles
      else
        @load_profiles.reject(&:deprecated?)
      end
    end

    private

    def selected_load_profiles(load_profiles, technology)
      if technology
        load_profiles[technology.key.to_s] || []
      else
        LoadProfile.order(:key)
      end
    end

    def profile_ids
      @profile_ids ||= @technology_profile.each_tech.map(&:profile).uniq
    end

    def selected_profiles
      @load_profiles.select do |profile|
        profile_ids.include?(profile.id)
      end
    end
  end
end
