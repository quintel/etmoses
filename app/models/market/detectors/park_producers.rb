module Market
  module Detectors
    class ParkProducers
      def measurables(stakeholder, network, variants)
        variants[:heat].object.head.get(:park).producers.select do |producer|
          producer.installed.stakeholder == stakeholder
        end
      end

      def variants_for(measurable, variants)
        Hash.new { ->* {} }
      end
    end # ParkProducers
  end # Measurables
end
