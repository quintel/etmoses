module Market
  # Takes a series of values, and treats them as if they were a different
  # length. For example:
  #
  #   curve = InterpolatedCurve.new([1, 2], 4)
  #   curve.at(0) # => 1
  #   curve.at(1) # => 1
  #   curve.at(2) # => 2
  #   curve.to_a  # => [1, 1, 2, 2]
  #
  class InterpolatedCurve < Network::Curve
    def self.new(values, length)
      unless (length % values.length).zero?
        fail InvalidInterpolationError.new(values.length, length)
      end

      repeat = (length / values.length).to_i

      Network::Curve.new(values.each_with_object([]) do |value, interp|
        repeat.times { interp.push(value) }
      end)
    end

    # Public: Creates a new InterpolatedCurve.
    #
    # values - The original curve: an enumerable containing one or more values.
    # length - The length to which the curve should interpolate. Must be
    #          divisible by the length of `values`.
    #
    # Returns an InterpolatedCurve.
    # def initialize(values, length)
      # unless (length % values.length).zero?
        # fail InvalidInterpolationError.new(values.length, length)
      # end

      # repeat = (length / values.length).to_i

      # super(values.each_with_object([]) do |value, interp|
        # repeat.times { interp.push(value) }
      # end)
    # end
  end
end
