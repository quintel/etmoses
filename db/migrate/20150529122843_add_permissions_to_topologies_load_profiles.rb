class AddPermissionsToTopologiesLoadProfiles < ActiveRecord::Migration
  def change
    add_column :topologies, :public, :boolean, after: :graph,
      default: true, null: false

    add_column :topologies, :user_id, :integer, after: :public

    add_column :load_profiles, :public, :boolean, after: :name,
      default: true, null: false

    add_column :load_profiles, :user_id, :string, after: :public
  end
end
