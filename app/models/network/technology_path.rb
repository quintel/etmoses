module Network
  # Represents a path from a specific technology in a node to the root node.
  class TechnologyPath
    extend Forwardable

    def_delegators :@technology,
      :production_at, :mandatory_consumption_at,
      :capacity_constrained?, :excess_constrained?

    # Public: Given a leaf node with one or more technologies, returns a
    # TechnologyPath for each technology present, and a path back to the source
    # of the graph.
    def self.find(leaf)
      path = Path.find(leaf)
      leaf.techs.map { |tech| new(tech, path) }
    end

    attr_reader :technology

    def initialize(technology, path)
      @technology = technology
      @path       = path
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
      "#<#{ self.class.name } #{ self }>"
    end

    def to_s
      "#{ @technology.installed.technology.name.inspect } | " \
        "{#{ @path.map(&:key).join(', ') }}"
    end

    def congested_at?(frame, correction = 0)
      @path.congested_at?(frame, correction)
    end

    def production_exceedance_at(frame)
      @path.map { |node| node.production_exceedance_at(frame) }.max
    end

    # Public: Sends a given amount of energy down the path, increasing the
    # consumption flow of each node.
    #
    # Returns nothing.
    def consume(frame, amount, conditional = false)
      # Don't assign remnants of floating point errors.
      amount = 0.0 if amount < 1e-10

      # Some technologies need to be explicitly told that they received no
      # (conditional) consumption.
      return if amount.zero? && ! @technology.respond_to?(:store)

      # TODO: "store" should be renamed to "consume_conditional"
      if conditional
        @technology.store(frame, amount)
      else
        # Hack hack hack. Required to tell components in a "composite"
        # technology what they have received.
        @technology.receive_mandatory(frame, amount)
      end

      currently = @technology.consumption[frame] || 0.0
      @technology.consumption[frame] = currently + amount

      @path.each { |node| node.consume(frame, amount) }
    end

    private

    def constrain(frame, amount)
      return amount unless @technology.capacity_constrained?

      headroom = @path.available_capacity_at(frame)

      if headroom < amount
        # Some techs work on the principle that if all of their conditional
        # consumption cannot be satisfied, none of it should.
        @technology.flexible_conditional? ? headroom : 0.0
      else
        amount
      end
    end
  end # TechnologyPath
end # Network
