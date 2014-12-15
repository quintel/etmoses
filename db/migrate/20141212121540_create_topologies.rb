class CreateTopologies < ActiveRecord::Migration
  def change
    create_table :topologies do |t|
      t.text    :graph,   limit: 16_777_215, null: false
      t.timestamps
    end
  end
end
