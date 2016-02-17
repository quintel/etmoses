class AddCanConcurToLoadProfiles < ActiveRecord::Migration
  def change
    add_column :load_profiles, :included_in_concurrency, :boolean, default: false
  end
end
