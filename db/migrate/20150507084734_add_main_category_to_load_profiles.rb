class AddMainCategoryToLoadProfiles < ActiveRecord::Migration
  def change
    load_profile_category = LoadProfileCategory.create!(name: "Main category")
    LoadProfile.update_all(load_profile_category_id: load_profile_category.id)
  end
end
