module Market::Measures
  module ParkKwhProduced
    def self.call(producer, *)
      KwhConsumed.call(producer)
    end
  end
end
