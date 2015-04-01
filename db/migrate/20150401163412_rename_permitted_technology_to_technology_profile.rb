class RenamePermittedTechnologyToTechnologyProfile < ActiveRecord::Migration
  def change
    rename_table :permitted_technologies, :technology_profiles
  end
end
