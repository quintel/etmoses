class Import
  CoefficientOfPerformanceAttribute =
    Attribute.new(
      'performance_coefficient',
      'coefficient_of_performance'
    ) do |value, *|
      value
    end
end
