module LoadProfilesHelper
  def load_profile_categories_select_options
    options_for_select(LoadProfileCategory.hierarchic_order.map do |l|
      ["#{ " - " * l.parent_count }#{ l.name }", l.id]
    end)
  end
end
