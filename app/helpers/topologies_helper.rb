module TopologiesHelper
  def topology_field_value(topology)
    if topology.new_record? && topology.graph.blank?
      Topology::DEFAULT_GRAPH
    elsif topology.graph.is_a?(String)
      topology.graph
    else
      YAML.dump(topology.graph.to_hash)
    end
  end

  def edge_nodes_for(topology)
    Topologies::EdgeNodesFinder.new(topology.graph).find_edge_nodes.map(&:key)
  end
end
