module Network
  class Curve < Merit::Curve
    HOURS_PER_YEAR = 8760

    # Public: The number of hours represented by each point in the curve. A
    # curve containing 8760 points has one point-per-hour, and therefore the
    # resolution is 1. A curve with 35,040 points has one per-fifteen-minutes
    # and has a resolution of 0.25.
    #
    # Returns a float.
    attr_reader :resolution

    def initialize(*args)
      super

      fail 'Curve must not be empty' if length.zero?
      @resolution = HOURS_PER_YEAR.to_f / length
    end
  end
end
