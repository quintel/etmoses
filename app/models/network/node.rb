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
    def load_at(point)
      load[point] ||= consumption_at(point) - production_at(point)
    end

    # Public: Returns the deficit or surplus of energy of the node based only on
    # the technologies assigned to it.
    def local_load_at(point)
      (techs = get(:techs)) ? techs.sum { |tech| tech.load_at(point) } : 0.0
    end

    # Public: Determines the production load of the node. This is the amount of
    # energy produced by all child nodes, without considering any which will be
    # consumed by their technologies.
    #
    # Returns a numeric.
    def production_at(point)
      @production[point] ||= recursively(:production_at, point)
    end

    # Public: The amount of energy currently assigned for the node to consume
    # in the chosen time point.
    #
    # Consumption cannot be simply calculated, like production, as these loads
    # will depend on how much excess -- if any -- is present in the testing
    # ground. Consumption is assigned by running the PullConsumption calculator.
    #
    # Returns a numeric.
    def consumption_at(point)
      @consumption[point] || 0.0
    end

    # Public: Increases the consumption of the node in the given point by the
    # amount.
    #
    # Returns the amount.
    def consume(point, amount)
      @consumption[point] ||= 0.0
      @consumption[point] += amount
    end

    # Public: Recurses through child nodes and technologies to determine the
    # absolute minimum amount of energy which the node requires to meet demand
    # from consumption technologies.
    #
    # Returns a numeric.
    def mandatory_consumption_at(point)
      @mandatory[point] ||= recursively(:mandatory_consumption_at, point)
    end

    # Public: Recurses through child nodes and technologies to determine the
    # how much extra energy the node would like, if there is an excess in the
    # testing ground, to further top-up its consumption technologies (likely
    # storage).
    #
    # Returns a numeric.
    def conditional_consumption_at(point)
      @conditional[point] ||= recursively(:conditional_consumption_at, point)
    end

    # Internal: Instructs the node that a mandatory load is being assigned to
    # fulfil the load demands of its consumption technologies.
    #
    # Returns nothing.
    def assign_mandatory_consumption(point, _)
      get(:techs).each do |tech|
        # Temporary work-around for storage needing to show a delta over
        # whatever was assigned in the previous point.
        tech.load[point] = -tech.stored_at(point) if tech.storage?
      end
    end

    # Internal: Instructs the node that a conditional load is being assigned to
    # fulfil the load demands of its consumption technologies. This load is the
    # result of an excess in the testing ground, and is kept in attached
    # storage technologies.
    #
    # Evenly distributes the load among the storage technologies.
    #
    # Returns nothing.
    def assign_conditional_consumption(point, amount)
      wanted = conditional_consumption_at(point)

      get(:techs).each do |tech|
        next unless tech.storage?

        share  = tech.conditional_consumption_at(point) / wanted
        assign = amount * share

        tech.load[point] ||= -tech.stored_at(point)
        tech.load[point] += assign
      end
    end

    #######
    private
    #######

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
    def recursively(method, point)
      from_children = memoized_out.sum { |node| node.__send__(method, point) }

      if get(:techs)
        from_children + get(:techs).sum { |tech| tech.__send__(method, point) }
      else
        from_children
      end
    end
  end # Node
end # Network
