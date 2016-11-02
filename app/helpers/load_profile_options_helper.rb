module LoadProfileOptionsHelper
  def options_for_load_profiles(technology, settings = {})
    profiles      = profiles_for_technology(technology)
    load_profiles = profiles.map do |load_profile|
      [load_profile.display_name, load_profile.id, data: default_values(load_profile)]
    end

    options_for_select(load_profiles,
      { selected: selected_load_profile(profiles) }.merge(settings))
  end

  def selected_load_profile(profiles)
    profiles.detect { |profile| profile.included_in_concurrency }.try(:id)
  end

  def profiles_for_technology(technology)
    LoadProfiles::Options.new(@load_profiles, technology).generate_options
  end
end
