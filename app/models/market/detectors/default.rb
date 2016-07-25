module Market
  module Detectors
    class Default
      def measurables(stakeholder, network, variants)
        network.nodes.select do |node|
          node.get(:stakeholder) == stakeholder
        end
      end

      def variants_for(measurable, variants)
        Hash[variants.map { |name, variant| [name, variant.call(measurable)] }]
      end
    end # Default
  end # Detectors
end
