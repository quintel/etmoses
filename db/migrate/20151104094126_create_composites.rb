class CreateComposites < ActiveRecord::Migration
  def change
    create_table :composites do |t|
      t.integer :technology_id
      t.integer :composite_id
    end
  end
end
