require 'turbine'
require 'virtus'

require_relative 'etloader/calculator'
require_relative 'etloader/technology'
require_relative 'etloader/version'

module ETLoader
  module_function

  # Public: Creates a Turbine graph to represent the given hash structure.
  #
  # nodes - An array of nodes to be added to the graph. Each element in the
  #         array should have a unique :name key to identify the node, and an
  #         optional :children key containing an array of child nodes.
  # techs - A hash where each key matches the key of a node, and each value is
  #         an array of technologies connected to the node. Optional.
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
  def build(nodes, techs = {}, graph = Turbine::Graph.new, parent = nil)
    nodes.each do |data|
      data = Hash[data.map { |key, value| [key.to_sym, value] }]
      node = graph.add(Turbine::Node.new(data[:name]))

      # Properties

      node.properties = data.dup.tap do |props|
        props.delete(:name)
        props.delete(:children)
      end

      # Technologies

      node_techs = techs[data[:name]] || {}

      node.set(:technologies, Hash[node_techs.map do |attrs|
        tech = Technology.new(attrs)
        [tech.name, tech]
      end])

      # Connections and children.

      parent.connect_to(node) if parent

      build(data[:children], techs, graph, node) if data[:children]
    end

    graph
  end
end # ETLoader
