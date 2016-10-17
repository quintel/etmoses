class CreateTopologyTemplates < ActiveRecord::Migration
  def change
    create_table :topology_templates do |t|
      t.integer :user_id, null: false
      t.boolean :public, default: true
      t.string :name, null: false
      t.text :graph, limit: 16_777_215, null: false
      t.timestamps
    end
  end
end
