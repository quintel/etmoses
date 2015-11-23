module Network
  # Describes a path of nodes from a technology node, back to the root.
  class Path
    extend Forwardable
    include Enumerable

    def_delegator :@path, :each

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

    def inspect
      "#<#{ self.class.name } #{ self }>"
    end

    def to_s
      "{#{ @path.map(&:key).join(', ') }}"
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

    # Public: Returns the minimum available capacity of the nodes in the path.
    # If capacity has been exceeded, 0.0 will be returned, while no set capacity
    # will return Infinity.
    #
    # Returns a numeric.
    def available_capacity_at(frame)
      @path.map { |node| node.available_capacity_at(frame) }.reject(&:nan?).min
    end

    # Public: Determines if the load of the any node in the path node exceeds
    # its capacity.
    #
    # Returns true or false.
    def congested_at?(frame, correction = 0)
      @path.any? { |node| node.congested_at?(frame, correction) }
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
