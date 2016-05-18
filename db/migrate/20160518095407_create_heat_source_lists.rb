class CreateHeatSourceLists < ActiveRecord::Migration
  def change
    create_table :heat_source_lists do |t|
      t.integer :testing_ground_id
      t.text :source_list
      t.timestamps
    end
  end
end
