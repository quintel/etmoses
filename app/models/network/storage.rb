module Network
  # A technology which, instead of producing or consuming energy, may do either
  # depending on the load of the network. Storage may retain consumed energy for
  # release back to the network later.
  class Storage < Technology
    # Public: Using the amount of energy stored in the technology in each time
    # step, determines the relative change in energy over time, giving the load
    # of the technology.
    #
    # Returns an array.
    def load
      @load ||= [stored.first, *stored.each_cons(2).map { |a, b| b - a }]
    end

    def load_at(point)
      load[point]
    end

    # Public: An array where each element describes the total amount of energy
    # stored in the technology in each time-step.
    #
    # Returns an array.
    def stored
      @stored ||= DefaultArray.new(&method(:mandatory_consumption_at))
    end

    def production_at(point)
      point.zero? ? 0.0 : stored[point - 1]
    end

    def mandatory_consumption_at(point)
      0.0
    end

    def conditional_consumption_at(point)
      (installed.storage || 0.0) - mandatory_consumption_at(point)
    end

    def consumer?
      false
    end

    def producer?
      false
    end

    def storage?
      true
    end

    # Public: Returns how much of the technology's capacity remains unused.
    def headroom_at(point)
      installed.storage - production_at(point)
    end
  end # Storage
end # Network
