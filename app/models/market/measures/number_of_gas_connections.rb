module Market::Measures
  module NumberOfGasConnections
    def self.call(node, variants)
      if variants[:gas].call
        NumberOfConnections.call(node)
      else
        0
      end
    end
  end
end
