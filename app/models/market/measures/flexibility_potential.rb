module Market::Measures
  # The average flexibility of the measurable throughout the year.
  FlexibilityPotential = lambda do |node, variants|
    flexes = Flexibility.new.call(node, variants)
    flexes.sum / flexes.length.to_f
  end
end
