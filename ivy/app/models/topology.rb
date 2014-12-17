class Topology < ActiveRecord::Base
  serialize :graph,        JSON
  serialize :technologies, JSON

  DEFAULT_GRAPH        = Rails.root.join('db/default_topology.yml').read
  DEFAULT_TECHNOLOGIES = Rails.root.join('db/default_technologies.yml').read

  validate :validate_technologies_used

  # Creates a hash representing the full topology to be rendered by D3. Copies
  # important attributes from the techologies hash into the topology.
  #
  # This should be moved to a presenter after the prototype stage.
  def as_json(*)
    { graph: format_children(graph), technologies: technologies }
  end

  # Traverses each node in the graph, yielding it's data.
  #
  # Returns nothing.
  def each_node(nodes = graph, &block)
    nodes.each do |node|
      block.call(node)
      each_node(node['children'], &block) if node['children']
    end
  end

  #######
  private
  #######

  # Traverses a list of topology children, merging in details about technologies
  # so that it may be rendered by D3.js. See `as_json`.
  def format_children(children)
    children.map do |child|
      child = child.clone

      if ! child['name'] && child['technology']
        child['name'] = technologies[child['technology']]['name']
      end

      if ! child['name']
        child['name'] = 'Un-named tech.'
      end

      if child['children']
        child['children'] = format_children(child['children'])
      end

      child
    end
  end

  # Asserts that the technologies used in the graph have all been defined in
  # the technologies collection.
  def validate_technologies_used
    each_node do |node|
      if node['technology'] && ! technologies.key?(node['technology'])
        errors.add(:graph,
                   "uses undefined technology #{ node['technology'].inspect }")
      end
    end
  end
end
