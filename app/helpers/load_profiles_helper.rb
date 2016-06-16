module LoadProfilesHelper
  def load_profile_categories_select_options(profile)
    load_profiles = LoadProfileCategory.tree_sort.map do |category|
      name = "#{ "- " * (category.path.length - 1) }#{ category.name }"

      [ name, category.id, { data: { curve_type: category.key } } ]
    end

    options_for_select(load_profiles, { selected: profile.load_profile_category_id })
  end

  def technologies_select_options(selected = nil)
    bufferables = @technologies.map(&:technologies).flatten

    options_for_select((Technology.visible - bufferables).map do |technology|
      [I18n.t("inputs.#{ technology.key }"), technology.key]
    end, selected)
  end
end
