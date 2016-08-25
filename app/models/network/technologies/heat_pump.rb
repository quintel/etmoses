module Network
  module Technologies
    # A buffer whose conditional consumption (buffering) may be limited by the
    # network capacity.
    class HeatPump < Buffer
      def self.disabled?(_options)
        false
      end

      def self.disabled_class
        self
      end

      def initialize(installed, profile, hp_capacity_constrained: false, **)
        super
        @capacity_constrained = hp_capacity_constrained
      end

      # Heat pumps, unlike other buffering technologies, may take energy from
      # the grid when buffering.
      def excess_constrained?
        false
      end

      def capacity_constrained?
        @capacity_constrained
      end
    end # HeatPump
  end
end
