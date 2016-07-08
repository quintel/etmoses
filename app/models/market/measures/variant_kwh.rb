module Market::Measures
  class VariantKwh
    def initialize(variant_name, direction)
      @variant_name = variant_name
      @direction    = direction
    end

    def call(node, variants)
      if variant = variants[@variant_name].call
        (@direction == :consumed ? KwhConsumed : KwhProduced).call(variant)
      else
        []
      end
    end
  end
end
