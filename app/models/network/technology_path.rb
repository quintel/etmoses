module Network
  # Represents a path from a specific technology in a node to the root node.
  class TechnologyPath
    # Public: Given a leaf node with one or more technologies, returns a
    # TechnologyPath for each technology present, and a path back to the source
    # of the graph.
    def self.find(leaf)
      path = Path.find(leaf)
      leaf.get(:techs).map { |tech| new(tech, path) }
    end

    attr_reader :technology

    def initialize(technology, path)
      @technology = technology
      @path       = path
    end

    # Public: The amount of energy produced by the technology.
    #
    # TODO Production should be capacity-constrained also if we are to support
    # curtailing production of solar PV.
    #
    # Returns a numeric.
    def production_at(frame)
      @technology.production_at(frame)
    end

    # Public: The mandatory consumption of the technology.
    #
    # Returns a numeric.
    def mandatory_consumption_at(frame)
      @technology.mandatory_consumption_at(frame)
    end

    # Public: Returns the conditional consumption required by the technology in
    # the given frame. If the technology supports flexibility, the consumption
    # will be reduced so as not to exceed the available capacity on the path.
    #
    # Returns a numeric.
    def conditional_consumption_at(frame)
      constrain(frame, @technology.conditional_consumption_at(frame))
    end

    def inspect
      "#<#{ self.class.name } #{ to_s }>"
    end

    def to_s
      "#{ @technology.to_s } | {#{ @path.map(&:key).join(', ') }}"
    end

    def congested_at?(frame)
      @path.congested_at?(frame)
    end

    def production_exceedance_at(frame)
      @path.map{|node| node.production_exceedance_at(frame) }.max
    end

    # Public: Sends a given amount of energy down the path, increasing the
    # consumption flow of each node.
    #
    # Returns nothing.
    def consume(frame, amount, conditional = false)
      # Some technologies need to be explicitly told that they received no
      # (conditional) consumption.
      return if amount.zero? && ! @technology.respond_to?(:store)

      # TODO "store" should be renamed to "consume_conditional"
      @technology.store(frame, amount) if conditional

      currently = @technology.consumption[frame] || 0.0
      @technology.consumption[frame] = currently + amount

      @path.each { |node| node.consume(frame, amount) }
    end

    #######
    private
    #######

    def constrain(frame, amount)
      return amount unless @technology.capacity_constrained?

      headroom = @path.available_capacity_at(frame)
      headroom < amount ? headroom : amount
    end
  end # TechnologyPath
end # Network
