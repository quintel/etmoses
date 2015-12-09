module Market::Measures
  module NumberOfGasConnections
    def self.call(node, variants)
      # Rails.logger.info ["=============", variants[:gas].call].inspect
      if variants[:gas].call
        NumberOfConnections.call(node)
      else
        0
      end
    end
  end
end
