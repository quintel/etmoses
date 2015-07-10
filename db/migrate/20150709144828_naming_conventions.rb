class NamingConventions < ActiveRecord::Migration
  def change
    rename_table :profiles, :load_profiles
    rename_table :profile_curves, :load_profile_components
  end
end
