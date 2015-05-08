module TopologiesHelper
  def topology_field_value(topology)
   if topology.new_record? && topology.graph.blank?
     Topology::DEFAULT_GRAPH
   else
     YAML.dump(topology.graph.to_hash)
   end
  end
end
