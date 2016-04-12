module NetworkCache
  module LoadSetter
    module_function

    # Public: Given a network and an array keys on which loads are to be
    # assigned, yields each node, expecting the block to return an array of
    # loads to be assigned.
    #
    # Returns the network.
    def set(network, selected_nodes = nil, attr = :load)
      keys = selected_nodes || network.nodes.map(&:key)

      keys.map { |key| network.node(key) }.compact.each do |node|
        node.set(attr, yield(node))
      end

      network
    end
  end # LoadSetter
end
