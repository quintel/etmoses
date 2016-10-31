class RemoveTopologyColumnFromTestingGrounds < ActiveRecord::Migration
  def change
    remove_column :testing_grounds, :topology_id
  end
end
