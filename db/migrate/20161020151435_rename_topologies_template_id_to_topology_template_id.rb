class RenameTopologiesTemplateIdToTopologyTemplateId < ActiveRecord::Migration
  def change
    rename_column :topologies, :template_id, :topology_template_id
  end
end
