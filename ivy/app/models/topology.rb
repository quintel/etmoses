class Topology < ActiveRecord::Base
  serialize :graph, JSON

  DEFAULT_GRAPH = Rails.root.join('db/default_topology.yml').read

  # Traverses each node in the graph, yielding it's data.
  #
  # Returns nothing.
  def each_node(nodes = [graph], &block)
    nodes.each do |node|
      block.call(node)
      each_node(node['children'], &block) if node['children']
    end
  end
end
