module LoadProfilesHelper
  def load_profile_categories_select_options(profile)
    load_profiles = LoadProfileCategory.tree_sort.map do |category|
      name = "#{ "- " * (category.path.length - 1) }#{ category.name }"

      [ name, category.id, { data: { curve_type: category.key } } ]
    end

    options_for_select(load_profiles, { selected: profile.load_profile_category_id })
  end

  def technologies_select_options(selected = nil)
    options_for_select(@technologies.map{|t| [t.name, t.key]}, {selected: selected})
  end
end
