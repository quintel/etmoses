class AddPermissionsToTestingGrounds < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :public, :boolean, after: :topology_id,
      default: true, null: false
  end
end
