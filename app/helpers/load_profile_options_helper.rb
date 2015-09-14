module LoadProfileOptionsHelper
  def options_for_load_profiles(technology = nil)
    load_profiles = profiles_for_technology(technology).map do |load_profile|
      [load_profile.key, load_profile.id, data: default_values(load_profile, technology)]
    end

    options_for_select(load_profiles)
  end

  def profiles_for_technology(technology)
    LoadProfiles::Options.new(@load_profiles, @testing_ground, technology)
      .generate_options
  end

  def default_values(load_profile, technology)
    Hash[%i(default_capacity default_volume default_demand).map do |default|
      [default,
       load_profile.send(default) || technology && technology.send(default)]
    end]
  end
end
