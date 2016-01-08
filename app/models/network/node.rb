module Network
  class Node < Turbine::Node
    def initialize(*args)
      super

      # Energy flows.
      @production  = []
      @consumption = []

      # Caches for different types of consumption.
      @mandatory   = []
      @conditional = []
    end

    # Public: An array describing the load of the node in each time step.
    def load
      get(:load) || set(:load, [])
    end

    # Public: The net load of the node in the given time step. A positive number
    # indicates that the node is consuming energy, a negative that it is
    # supplying energy to its parent.
    #
    # Returns a numeric.
    def load_at(frame)
      consumption_at(frame) - production_at(frame)
    end

    def cache_load_at!(frame)
      load[frame] = load_at(frame)
    end

    # Public: Determines how much energy the node receives or emits in a chosen
    # frame. Requires first that the entire frame has been calculated, and the
    # load cached.
    #
    # Returns a float.
    def energy_at(frame)
      load[frame] * get(:resolution)
    end

    # Public: Determines the production load of the node. This is the amount of
    # energy produced by all child nodes, without considering any which will be
    # consumed by their technologies.
    #
    # Returns a numeric.
    def production_at(frame)
      @production[frame] ||= recursively(:production_at, frame)
    end

    # Public: The amount of energy currently assigned for the node to consume
    # in the chosen time frame.
    #
    # Consumption cannot be simply calculated, like production, as these loads
    # will depend on how much excess -- if any -- is present in the testing
    # ground. Consumption is assigned by running the PullConsumption calculator.
    #
    # Returns a numeric.
    def consumption_at(frame)
      @consumption[frame] || 0.0
    end

    # Public: Increases the consumption of the node in the frame by the given
    # amount.
    #
    # Returns the amount.
    def consume(frame, amount)
      @consumption[frame] ||= 0.0
      @consumption[frame] += amount
    end

    # Public: Recurses through child nodes and technologies to determine the
    # absolute minimum amount of energy which the node requires to meet demand
    # from consumption technologies.
    #
    # Returns a numeric.
    def mandatory_consumption_at(frame)
      @mandatory[frame] ||= recursively(:mandatory_consumption_at, frame)
    end

    # Public: Recurses through child nodes and technologies to determine the
    # how much extra energy the node would like, if there is an excess in the
    # testing ground, to further top-up its consumption technologies (likely
    # storage).
    #
    # Returns a numeric.
    def conditional_consumption_at(frame)
      @conditional[frame] ||= recursively(:conditional_consumption_at, frame)
    end

    # Internal: Instructs the node that a conditional load is being assigned to
    # fulfil the load demands of its consumption technologies. This load is the
    # result of an excess in the testing ground, and is kept in attached
    # storage technologies.
    #
    # Evenly distributes the load among the storage technologies.
    #
    # Returns nothing.
    def assign_conditional_consumption(frame, amount)
      wanted = conditional_consumption_at(frame)

      techs.each do |tech|
        next unless tech.storage?

        share  = tech.conditional_consumption_at(frame) / wanted
        assign = amount * share

        tech.store(frame, assign)
      end
    end

    # Public: If the node has a capacity restriction, returns by how much the
    # load may be increased before reaching the limit. Returns infinity if no
    # capacity is present.
    #
    # TODO This would be better as a separate Constraint class.
    #
    # Returns a float.
    def consumption_margin_at(frame, correction = 0)
      capacity_margin(load_at(frame) + correction)
    end

    # Legacy alias. TODO Remove.
    alias_method :available_capacity_at, :consumption_margin_at

    # Public: Determines by how much production may be increased on this node
    # before reaching the capacity constraint.
    #
    # TODO This would be better as a separate Constraint class.
    #
    # Returns a float.
    def production_margin_at(frame, correction = 0)
      capacity_margin(-load_at(frame) - correction)
    end

    # Public: Determines if the consumption or production of the node exceeds
    # its capacity.
    #
    # Returns true or false.
    def congested_at?(frame, correction = 0)
      capacity = get(:capacity)
      capacity && load_at(frame).abs + correction > capacity
    end

    # Public: Returns by how much production on across this node exceeds the
    # assigned capacity. Returns zero if there is no exceedance.
    #
    # Returns a float.
    def production_exceedance_at(frame, correction = 0)
      current_load = (load_at(frame) - correction)

      if congested_at?(frame, correction) && current_load < 0
        current_load.abs - (get(:capacity) || 0)
      else
        0
      end
    end

    # Public: Returns by how much consumption on across this node exceeds the
    # assigned capacity. Returns zero if there is no exceedance.
    #
    # Returns a float.
    def consumption_exceedance_at(frame, correction = 0)
      current_load = current_load = load_at(frame) + correction

      if congested_at?(frame, correction) && current_load > 0
        current_load - (get(:capacity) || 0)
      else
        0
      end
    end

    # Public: An array of technologies attached to this node.
    #
    # Returns an array.
    def techs
      get(:techs) || set(:techs, [])
    end

    # Public: An integer that returns the lifetime of this node
    #
    # Returns an integer
    def lifetime
      get(:technical_lifetime) || get(:economic_lifetime)
    end

    # Public: An integer that returns the units of this node
    #
    # Returns an integer
    def units
      get(:units) || 1
    end

    private

    # Internal: A memoized list of child nodes. Since the graph never changes
    # during calculation, this is faster then getting the a fresh child list
    # in each time step.
    def memoized_out
      @memoized_out ||= nodes(:out)
    end

    # Given a method to call, recursively calls it on all child nodes and
    # technologies.
    #
    # Returns the sum of the value from the child nodes and techs.
    def recursively(method, frame)
      from_children = memoized_out.sum { |node| node.__send__(method, frame) }
      from_children + techs.sum { |tech| tech.__send__(method, frame) }
    end

    # Determines how much capacity is available given a particular `load` placed
    # on the node.
    #
    # Returns a float.
    def capacity_margin(load)
      capacity = get(:capacity)

      if capacity.nil?
        return load < 0 ? Float::INFINITY : Float::INFINITY
      end

      available = capacity - load
      available <= 0 ? 0.0 : available
    end
  end # Node
end # Network
