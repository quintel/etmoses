module LoadProfilesHelper
  def load_profile_categories_select_options(profile)
    load_profiles = LoadProfileCategory.tree_sort.map do |category|
      name = "#{ "- " * (category.path.length - 1) }#{ category.name }"

      [ name, category.id, { data: { curve_type: category.key } } ]
    end

    options_for_select(load_profiles, { selected: profile.load_profile_category_id })
  end

  def technologies_select_options(selected = nil)
    profile_techs = Technology.all.select do |tech|
      tech.whitelisted_attributes.include?('profile')
    end

    options = carrier_grouped_technologies(profile_techs) do |tech|
      namespace = tech.carrier == 'heat' ? 'heat_sources' : 'inputs'
      [I18n.t("#{ namespace }.#{ tech.key }"), tech.key]
    end

    grouped_options_for_select(options, selected)
  end
end
