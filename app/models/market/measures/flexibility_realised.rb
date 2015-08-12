module Market::Measures
  # The sum of all flexibility for the measurable throughout the year.
  FlexibilityRealised = lambda do |node, variants|
    Flexibility.new.call(node, variants).sum
  end
end
