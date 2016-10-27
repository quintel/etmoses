class RemoveStringValuesFromTopologies < ActiveRecord::Migration
  def up
    Topology.where("`graph` LIKE '%\"investment_cost\":\"\"%'").each do |topology|
      graph = topology.graph.to_json

      graph.gsub!("\"investment_cost\":\"\"", "\"investment_cost\":null")
      graph.gsub!("\"technical_lifetime\":\"\"", "\"technical_lifetime\":null")
      graph.gsub!("\"capacity\":\"\"", "\"capacity\":null")

      topology.graph = graph
      topology.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
