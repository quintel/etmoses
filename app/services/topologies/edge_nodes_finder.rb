module Topologies
  #
  # Given a topology
  # Returns the edge nodes of that topology.
  #
  class EdgeNodesFinder
    def initialize(topology)
      @topology = topology
    end

    def find_edge_nodes
      all_topology_nodes.select do |n|
        n.edges(:out).empty?
      end
    end

    private

    def all_topology_nodes
      Network::Builders::Electricity.build(@topology).nodes
    end
  end
end
