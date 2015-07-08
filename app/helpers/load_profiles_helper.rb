module LoadProfilesHelper
  def load_profile_categories_select_options
    options_for_select(LoadProfiles::Hierarchy.new.tree_sort.map do |l|
      ["#{ "- " * l[:path_size] }#{ l[:load_profile_category].name }",
        l[:load_profile_category].id]
    end)
  end

  def technologies_select_options
    options_for_select(@technologies.map{|t| [t.name, t.key]})
  end
end
