module LoadProfiles
  class Options
    #
    # Class to generate options for load profiles
    #
    def initialize(load_profiles, technology)
      @load_profiles = selected_load_profiles(load_profiles, technology)
    end

    def generate_options
      @load_profiles.reject(&:deprecated?)
    end

    private

    def selected_load_profiles(load_profiles, technology)
      if technology.key =~ /^generic/
        LoadProfile.order(:key)
      else
        load_profiles[technology.key.to_s] || []
      end
    end
  end
end
