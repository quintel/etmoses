module LoadProfileOptionsHelper
  def options_for_load_profiles(technologies, technology = false)
    tech_profiles = technology ? technology.load_profiles : LoadProfile.order(:key)

    load_profiles = profiles(technologies, tech_profiles).map do |load_profile|
      [load_profile.key, load_profile.id, data: default_values(load_profile, technology)]
    end

    options_for_select(load_profiles)
  end

  def profiles(technologies, load_profiles)
    profile_ids = technologies.values.flatten.map{|t| t[:profile] }.uniq

    if LoadProfile.find(profile_ids).any?(&:deprecated?)
      load_profiles
    else
      load_profiles.not_deprecated
    end
  end

  def default_values(load_profile, technology)
    Hash[%i(default_capacity default_volume default_demand).map do |default|
      [default,
       load_profile.send(default) || technology && technology.send(default)]
    end]
  end
end
