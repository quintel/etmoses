class CreateAssetLists < ActiveRecord::Migration
  def change
    create_table :asset_lists do |t|
      t.belongs_to(:testing_ground)
      t.text :type
      t.text :asset_list
      t.timestamps
    end
  end
end
