module LoadProfileOptionsHelper
  def options_for_load_profiles(technologies, technology = false)
    tech_profiles = technology ? technology.load_profiles : LoadProfile

    load_profiles = profiles(technologies, tech_profiles).map do |load_profile|
      [load_profile.key, load_profile.id]
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
end
