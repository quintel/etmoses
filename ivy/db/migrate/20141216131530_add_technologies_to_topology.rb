class AddTechnologiesToTopology < ActiveRecord::Migration
  def change
    add_column :topologies, :technologies, :text, limit: 16777215
  end
end
