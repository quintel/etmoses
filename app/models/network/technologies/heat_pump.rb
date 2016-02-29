module Network
  module Technologies
    # A buffer whose conditional consumption (buffering) may be limited by the
    # network capacity.
    class HeatPump < Buffer
      def self.build(installed, profile, options)
        if installed.buffer.blank? && ! options[:no_legacy_fallback]
          # Old scenarios have heat pumps modelled with an internal buffer
          # instead being attached to a shared buffer.
          LegacyBuffer.build(installed, profile, options)
        else
          super
        end
      end

      def initialize(installed, profile, hp_capacity_constrained: false, **)
        super
        @capacity_constrained = hp_capacity_constrained
      end

      def capacity_constrained?
        @capacity_constrained
      end
    end # HeatPump
  end
end
