class CurveCollection
  include Enumerable

  def initialize(components)
    @components = components
  end

  # Public: Iterates through each curve component, in order of their curve type
  # attribute.
  def each
    return enum_for(:each) unless block_given?

    @components.sort_by { |c| c.curve_type.to_s }.each do |*args|
      yield(*args)
    end
  end

  # Public: Iterates through each curve in the collection, yielding its type,
  # the curve values scaled as appropriate, and the ratio of the values in the
  # curve as a sum of the values in all the curves in the collection.
  #
  # Returns nothing.
  def each_curve(scaling = nil)
    return enum_for(:each_curve, scaling) unless block_given?

    each do |component|
      yield([
        component.curve_type,
        component.scaled_network_curve(scaling),
        ratio(component)
      ])
    end
  end

  private

  def ratio(component)
    component.network_curve.reduce(:+) / sum
  end

  def sum
    @sum ||= @components.map(&:network_curve).reduce(:+).reduce(:+)
  end
end
