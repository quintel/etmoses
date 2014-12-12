class CreateTopologies < ActiveRecord::Migration
  def change
    create_table :topologies do |t|
      t.text    :graph,   limit: 16_777_215, null: false
      t.integer :version,                    null: false, default: 1
      t.timestamps
    end
  end
end
