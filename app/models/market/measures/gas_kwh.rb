module Market::Measures
  class GasKwh
    def initialize(direction)
      @direction = direction
    end

    def call(node, variants)
      if gas = variants[:gas].call
        if @direction == :consumed
          KwhConsumed.call(gas)
        else
          KwhProduced.call(gas)
        end
      else
        0.0
      end
    end
  end
end
