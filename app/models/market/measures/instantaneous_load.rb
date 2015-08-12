module Market::Measures
  InstantaneousLoad = lambda do |node|
    node.load.blank? ? fail(Market::NoLoadError, node) : node.load
  end
end
