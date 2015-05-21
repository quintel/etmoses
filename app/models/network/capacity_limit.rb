module Network
  # Technologies - particularly storage technologies - may have variable
  # consumption depending on available excesses in the network. However, they
  # also have a capacity: the maximum amount of load which may be received or
  # emitted in each frame.
  #
  # Technologies typically return consumption as if capacity is unlimited; this
  # class ensures that the consumption does not exceed the capacity.
  class CapacityLimit
    attr_reader :capacity, :volume

    def initialize(technology = technology)
      @technology = technology
      @volume     = technology.installed.storage
      @capacity   = technology.installed.capacity || Float::INFINITY
    end

    # Public: Limit the mandatory consumption of a technology so that is does
    # not exceed the capacity.
    #
    # If the desired consumption is too high, the maximum permitted consumption
    # is returned instead.
    #
    # Returns a number.
    def limit_mandatory(frame, value)
      min(max(value, min_at(frame)), max_at(frame))
    end

    # Public: Limit the conditional consumption of a technology so that the
    # combined mandatory and conditional consumption does not exceed the
    # capacity.
    #
    # If the desired conditional consumption is too high, the maximum permitted
    # consumption is returned instead.
    #
    # Returns a number.
    def limit_conditional(frame, value)
      min(value, max_at(frame) - @technology.mandatory_consumption_at(frame))
    end

    #######
    private
    #######

    def max(a, b)
      a > b ? a : b
    end

    def min(a, b)
      a < b ? a : b
    end

    def max_at(frame)
      min(@technology.production_at(frame) + @capacity, @volume)
    end

    def min_at(frame)
      max(0.0, @technology.production_at(frame) - @capacity)
    end
  end # CapacityLimit
end # Network
