module Network
  # A technology which, instead of producing or consuming energy, may do either
  # depending on the load of the network. Storage may retain consumed energy for
  # release back to the network later.
  class Storage < Technology
    extend Disableable

    def self.disabled?(options)
      options[:solar_storage]
    end

    def initialize(*)
      super
      @capacity = CapacityLimit.new(self)
    end

    # Public: Using the amount of energy stored in the technology in each time
    # step, determines the relative change in energy over time, giving the load
    # of the technology.
    #
    # Returns an array.
    def load
      @load ||= [stored.first, *stored.each_cons(2).map { |a, b| b - a }]
    end

    def load_at(frame)
      load[frame]
    end

    # Public: An array where each element describes the total amount of energy
    # stored in the technology in each time-step.
    #
    # Returns an array.
    def stored
      @stored ||= DefaultArray.new(&method(:mandatory_consumption_at))
    end

    def production_at(frame)
      frame.zero? ? 0.0 : stored[frame - 1]
    end

    def mandatory_consumption_at(frame)
      @capacity.limit_mandatory(frame, 0.0)
    end

    def conditional_consumption_at(frame)
      @capacity.limit_conditional(
        frame, volume - mandatory_consumption_at(frame))
    end

    def store(frame, amount)
      stored[frame] += amount
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
  end # Storage
end # Network
