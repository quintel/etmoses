class AddLoadProfileCategoryIdToLoadProfiles < ActiveRecord::Migration
  def change
    add_column :load_profiles, :load_profile_category_id, :integer, after: :name
  end
end
