class MoveTopologiesToTemplates < ActiveRecord::Migration
  def up
    topologies = Topology.where("graph != ''")

    topologies.each do |topology|
      template         = TopologyTemplate.new
      template.graph   = topology.graph
      template.name    = topology.name || "Unknown name"
      template.public  = topology.public
      template.user_id = topology.user_id || User.orphan.id

      puts topology.id

      template.save

      topology.update_column(:original_id, template.id)
    end

    remove_column :topologies, :name
    remove_column :topologies, :public
    remove_column :topologies, :user_id
    rename_column :topologies, :original_id, :template_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
