class AddPermissionsToTestingGrounds < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :permissions, :string, after: :topology_id, default: 'public'
  end
end
