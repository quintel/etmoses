class RenameLoadProfilesToProfiles < ActiveRecord::Migration
  def change
    rename_table :load_profiles, :profiles
  end
end
