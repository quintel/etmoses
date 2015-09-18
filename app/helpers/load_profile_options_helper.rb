module LoadProfileOptionsHelper
  def options_for_load_profiles(technology_profile, technology = nil)
    load_profiles = profiles_for_technology(technology_profile, technology).map do |load_profile|
      [load_profile.key, load_profile.id, data: default_values(load_profile)]
    end

    options_for_select(load_profiles)
  end

  def profiles_for_technology(technology_profile, technology)
    LoadProfiles::Options.new(@load_profiles, technology_profile, technology)
      .generate_options
  end
end
