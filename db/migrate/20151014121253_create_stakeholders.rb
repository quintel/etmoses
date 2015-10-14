class CreateStakeholders < ActiveRecord::Migration
  def change
    create_table :stakeholders do |t|
      t.string :name
      t.integer :parent_id
    end
  end
end
