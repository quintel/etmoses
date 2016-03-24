module Network
  class Curve < Merit::Curve
    HOURS_IN_YEAR    = 8760
    QUARTERS         = [35040, 673]
    HIGH_RESOLUTION  = 0.25
    LOW_RESOLUTION   = 1.0

    # Public: Wraps the given enumerable in a Network::Curve. If the argument
    # is already a curve (or subclass thereof), it will be returned without
    # modification. Think: Array(thing).
    #
    # Returns a Network::Curve.
    def self.from(enumerable)
      enumerable.is_a?(self) ? enumerable : new(enumerable.to_a)
    end

    def initialize(*args)
      super

      fail 'Curve must not be empty' if length.zero?
    end

    def frames_per_hour
      1.0 / resolution
    end

    # Public: The number of hours represented by each point in the curve. A
    # curve containing 8760 points has one point-per-hour, and therefore the
    # resolution is 1. A curve with 35,040 points has one per-fifteen-minutes
    # and has a resolution of 0.25.
    #
    # Returns a float.
    def resolution
      case length
      when *QUARTERS
        HIGH_RESOLUTION
      when HOURS_IN_YEAR
        LOW_RESOLUTION
      else
        HOURS_IN_YEAR / length
      end
    end
  end
end
