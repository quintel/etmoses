class Topology < ActiveRecord::Base
  serialize :graph, JSON

  DUMMY_GRAPH = [
    { 'name' => 'HV Network', 'children' => [
      { 'name' => '...', 'children' => [{ 'name' => '...' }] },
      { 'name' => '...' }
    ]}
  ].freeze

  def graph
    super || DUMMY_GRAPH
  end

  def graph=(new_graph)
    if new_graph.is_a?(String)
      new_graph = YAML.parse(new_graph)
    end

    super(new_graph)
  end
end
