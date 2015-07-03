module LoadProfilesHelper
  def load_profile_categories_select_options
    options_for_select(LoadProfiles::Hierarchy.new.tree_sort.map do |category|
      [ "#{ "- " * category[:path_size] }#{ category[:load_profile_category].name }",
        category[:load_profile_category].id,
        { data: { number_of_rows: category[:load_profile_category].number_of_curves } }
      ]
    end)
  end

  def technologies_select_options
    options_for_select(@technologies.map{|t| [t.name, t.key]})
  end
end
