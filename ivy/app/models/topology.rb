class Topology < ActiveRecord::Base
  serialize :graph, JSON

  DEFAULT_GRAPH = Rails.root.join('db/default_topology.yml').read

  validate :validate_node_names

  # Traverses each node in the graph, yielding it's data.
  #
  # Returns nothing.
  def each_node(nodes = [graph], &block)
    nodes.each do |node|
      block.call(node)

      each_node(node['children'], &block) if node['children']
      each_node(node[:children], &block)  if node[:children]
    end
  end

  #######
  private
  #######

  def validate_node_names
    seen = Set.new

    each_node do |node|
      name = node[:name] || node['name'.freeze]

      if name.blank?
        errors.add(:graph, "has an unnamed component")
      elsif seen.include?(name)
        errors.add(:graph, "has a duplicate component: #{ name.inspect }")
      end

      seen.add(name)
    end
  end
end
