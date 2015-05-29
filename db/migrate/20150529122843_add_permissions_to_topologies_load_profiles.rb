class AddPermissionsToTopologiesLoadProfiles < ActiveRecord::Migration
  def change
    add_column :topologies, :permissions, :string, after: :graph, default: 'public'
    add_column :topologies, :user_id, :integer, after: :permissions
    add_column :load_profiles, :permissions, :string, after: :name, default: 'public'
    add_column :load_profiles, :user_id, :string, after: :permissions
  end
end
