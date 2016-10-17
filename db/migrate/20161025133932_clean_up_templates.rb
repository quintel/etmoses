class CleanUpTemplates < ActiveRecord::Migration
  def up
    user = User.where(email: "chael.kruip@quintel.com")

    # Topologies with no LES
    Topology.where(testing_ground_id: nil).destroy_all

    # Old topologies from Chael Kruip without a name
    TopologyTemplate.where(user: user, name: "Unknown name").destroy_all

    # Templates with the same content inside `graph`
    remove_topology_template_ids = (TopologyTemplate.pluck(:id) -
                                    TopologyTemplate.group(:graph).pluck(:id))

    TopologyTemplate.where(id: remove_topology_template_ids).destroy_all

    Topology
      .where(topology_template_id: remove_topology_template_ids)
      .update_all(topology_template_id: nil)

    # Templates wit the same content inside `interactions`
    remove_market_model_template_ids = (MarketModelTemplate.pluck(:id) -
                                        MarketModelTemplate.group(:interactions).pluck(:id))

    MarketModelTemplate.where(id: remove_market_model_template_ids).destroy_all
    MarketModel
      .where(market_model_template_id: remove_market_model_template_ids)
      .update_all(market_model_template_id: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
