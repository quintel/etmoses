module Market::Measures
  class CentralHeatKwhProduced
    # The top-most node in the heat network is where the production park is
    # found. The energy produced by the park will be logged as positive load
    # (consumption by the endpoints), therefore we measure the energy *consumed*
    # across this node, instead of the amount *produced*.
    def self.call(node, variants)
      return 0.0 unless variant = variants[:heat].call
      return 0.0 unless variant.edges(:in).none?

      KwhConsumed.call(variant)
    end
  end
end
