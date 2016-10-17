module TopologyGraph
  extend ActiveSupport::Concern

  included do
    serialize :graph, JSON

    validate :validate_node_names
    validate :validate_units
    validate :validate_children
    validate :validate_stakeholders
  end

  def graph=(graph)
    if graph.is_a?(String)
      super(JSON.parse(graph))
    else
      super(graph)
    end
  end

  # Traverses each node in the graph, yielding it's data.
  #
  # Returns nothing.
  def each_node(nodes = [graph], &block)
    return if self.errors[:graph].any?
    return enum_for(:each_node, nodes) unless block_given?

    nodes.compact.map(&:symbolize_keys).each do |node|
      block.call(node)
      each_node(node[:children], &block) if node[:children].is_a?(Array)
    end
  end

  private

  def validate_children
    each_node do |node|
      if ! node[:children].nil? && ! node[:children].is_a?(Array)
        errors.add(:graph, "contains invalid children on #{node[:name]}")
      end
    end
  end

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

  def validate_units
    each_node do |node|
      next unless node[:units]

      if ! node[:units].is_a?(Numeric)
        errors.add(:graph, "may not have a non-numeric \"units\" attribute")
      elsif node[:units] < 0
        errors.add(:graph, "may not have a node with \"units\" less than " \
                           "zero: #{ node[:name].inspect }")
      end
    end
  end

  def validate_stakeholders
    each_node do |node|
      next unless node[:stakeholder]

      unless Stakeholder.pluck(:name).include?(node[:stakeholder])
        errors.add(:graph, "contains a non existing stakeholder")
      end
    end
  end
end
