module Network
  # Describes a path of nodes from a technology node, back to the root.
  class Path
    # Public: Given a leaf node, returns a Path which represents the route
    # back to the root node.
    #
    # Returns a Path.
    def self.find(leaf)
      new([leaf, *leaf.ancestors.to_a])
    end

    # Internal: Creates a new Path, using the given array of nodes to describe
    # the path through the parents to the root node.
    def initialize(nodes)
      @path = nodes
      @leaf = nodes.first
    end

    # Public: The path as an array, with the leaf node first, with each node
    # leading to the root.
    def to_a
      @path.to_a
    end

    # Public: The conditional consumption being created by the consumption node.
    #
    # Returns a numeric.
    def conditional_consumption_at(frame)
      @leaf.conditional_consumption_at(frame)
    end

    # Public: The mandatory consumption being created by the consumption node.
    #
    # Returns a numeric.
    def mandatory_consumption_at(frame)
      @leaf.mandatory_consumption_at(frame)
    end

    # Public: Sends a given amount of energy down the path, increasing the
    # consumption flow of each node.
    #
    # Returns nothing.
    def consume(frame, amount)
      return if amount.zero?

      if @leaf.consumption_at(frame) >= mandatory_consumption_at(frame)
        @leaf.assign_conditional_consumption(frame, amount)
      end

      @path.each { |node| node.consume(frame, amount) }
    end
  end # Path
end # Network
