require 'turbine'

require_relative 'etloader/version'

module ETLoader
  module_function

  # Public: Creates a Turbine graph to represent the given hash structure.
  #
  # nodes - An array of nodes to be added to the graph. Each element in the
  #         array should have a unique :name key to identify the node, and an
  #         optional :children key containing an array of child nodes.
  #
  # For example:
  #
  #   nodes = YAML.load(<<-EOS.gsub(/  /, ''))
  #     ---
  #     - name: HV Network
  #       children:
  #       - name: MV Network
  #         children:
  #         - name: "LV #1"
  #         - name: "LV #2"
  #         - name: "LV #3"
  #   EOS
  #
  #   ETLoader.build(structure)
  #   # => #<Turbine::Graph (5 nodes, 4 edges)>
  #
  # Returns a Turbine::Graph.
  def build(nodes, graph = Turbine::Graph.new, parent = nil)
    nodes.each do |data|
      data = Hash[data.map { |key, value| [key.to_sym, value] }]
      node = graph.add(Turbine::Node.new(data[:name]))

      parent.connect_to(node) if parent

      build(data[:children], graph, node) if data[:children]
    end

    graph
  end
end # ETLoader
