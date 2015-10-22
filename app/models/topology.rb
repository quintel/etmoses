class Topology < ActiveRecord::Base
  include Privacy

  serialize :graph, JSON

  DEFAULT_GRAPH = Rails.root.join('db/default_topology.yml').read

  belongs_to :user
  belongs_to :original, class: Topology

  validates_presence_of :name

  validate :validate_graph_yaml
  validate :validate_node_names
  validate :validate_units
  validate :validate_stakeholders
  validate :validate_clone

  def self.default
    find_by_name("Default topology")
  end

  def self.in_name_order
    order(:name)
  end

  def self.named
    where("`name` IS NOT NULL").in_name_order
  end

  # Traverses each node in the graph, yielding it's data.
  #
  # Returns nothing.
  def each_node(nodes = [graph], &block)
    return if self.errors[:graph].any?
    return enum_for(:each_node, nodes) unless block_given?

    nodes.compact.map(&:symbolize_keys).each do |node|
      block.call(node)
      each_node(node[:children], &block) if node[:children]
    end
  end

  private

  def validate_graph_yaml
    begin
      self.graph = if graph.is_a?(String)
        YAML.load(graph.gsub(/\t/, ' ' * 4)) || {}
      else
        graph
      end
    rescue Psych::SyntaxError => e
      errors.add(:graph, e.message)
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

  def validate_clone
    return if original.blank? || errors[:graph].any?

    if each_node.count != original.each_node.count
      errors.add(:graph, "doesn't allow to remove a child from a topology. Please make"\
                "a new topology through the topologies menu and create a new LES.")
    end
  end
end
