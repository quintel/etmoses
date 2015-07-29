module LoadProfilesHelper
  def load_profile_categories_select_options
    options_for_select(LoadProfiles::Hierarchy.new.tree_sort.map do |category|
      [ "#{ "- " * category[:path_size] }#{ category[:load_profile_category].name }",
        category[:load_profile_category].id,
        { data: { curve_type: category[:load_profile_category].key } }
      ]
    end)
  end

  def technologies_select_options(selected = nil)
    options_for_select(@technologies.map{|t| [t.name, t.key]}, {selected: selected})
  end
end
