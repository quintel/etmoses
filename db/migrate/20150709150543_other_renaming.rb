class OtherRenaming < ActiveRecord::Migration
  def change
    rename_column :load_profile_components, :profile_id, :load_profile_id
    remove_column :load_profiles, :type
  end
end
