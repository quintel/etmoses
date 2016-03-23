module Network
  # Represents a path from a specific technology in a node to the root node.
  class TechnologyPath
    extend Forwardable

    def_delegators :@technology,
      :production_at, :mandatory_consumption_at,
      :capacity_constrained?, :excess_constrained?

    def_delegators :@path, :head, :leaf, :to_a, :length

    # Used by SubPaths
    attr_reader :receipts

    # Public: Given a leaf node with one or more technologies, returns a
    # TechnologyPath for each technology present, and a path back to the source
    # of the graph.
    def self.find(leaf)
      path = Path.find(leaf)
      leaf.techs.map { |tech| tech.path_class.new(tech, path) }
    end

    attr_reader :technology
    attr_reader :path

    def initialize(technology, path)
      @technology = technology
      @path       = path
      @flexible   = @technology.flexible_conditional?
      @receipts   = Receipts.new
    end

    def sub_paths
      @sub_paths ||= sub_path_class.from(self)
    end

    def mandatory_consumption_at(frame)
      amount = @technology.mandatory_consumption_at(frame) - receipts.mandatory[frame]
      amount <= 0 ? 0.0 : amount
    end

    # Public: Returns the conditional consumption required by the technology in
    # the given frame. If the technology supports flexibility, the consumption
    # will be reduced so as not to exceed the available capacity on the path.
    #
    # Returns a numeric.
    def conditional_consumption_at(frame)
      amount = @technology.conditional_consumption_at(frame) - receipts.conditional[frame]
      amount <= 0 ? 0.0 : constrain(frame, amount)
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

    def production_exceedance_at(frame, with = 0.0)
      @path.map { |node| node.production_exceedance_at(frame, with) }.max
    end

    def consumption_exceedance_at(frame, with = 0.0)
      @path.map { |node| node.consumption_exceedance_at(frame, with) }.max
    end

    def production_margin_at(frame, with = 0.0)
      @path.map { |node| node.production_margin_at(frame, with) }.min
    end

    def consumption_margin_at(frame, with = 0.0)
      @path.map { |node| node.consumption_margin_at(frame, with) }.min
    end

    def surplus_at(frame)
      head_load = @path.head.load_at(frame)
      head_load.zero? ? 0.0 : -head_load
    end

    # Public: Describes the amount of excess energy available at the head of
    # the path. There is an excess if (available) production exceeds
    # consumption.
    #
    # Returns a numeric.
    def excess_at(frame)
      flow = head.load_at(frame)
      flow < 0 ? flow.abs : 0.0
    end

    # Public: Returns true if a conditional consumption load has been assigned
    # to this path in the given frame. False otherwise.
    def received_conditional_at?(frame)
      @receipts[frame] && ! @receipts[frame].zero?
    end

    # Public: Returns how far the head node of the path is from the head node of
    # the network. See SubPath#distance.
    #
    # Returns an integer.
    def distance
      0
    end

    def subpath?
      false
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

      if conditional
        # TODO: "store" should be renamed to "consume_conditional"
        @technology.store(frame, amount)
        receipts.conditional[frame] += amount
      else
        # Hack hack hack. Required to tell components in a "composite"
        # technology what they have received.
        @technology.receive_mandatory(frame, amount)
        receipts.mandatory[frame] += amount
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
        @flexible ? headroom : 0.0
      else
        amount
      end
    end

    def sub_path_class
      SubPath
    end
  end # TechnologyPath
end # Network
