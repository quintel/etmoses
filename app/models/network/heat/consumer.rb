module Network
  module Heat
    class Consumer < Technologies::Generic
      attr_writer :park

      def initialize(*)
        super
        @capacity = CapacityLimit.new(self)
      end

      def production_at(_frame)
        0.0
      end

      def mandatory_consumption_at(frame)
        @capacity.limit_mandatory(frame, @profile.at(frame))
      end

      def conditional_consumption_at(_frame)
        0.0
      end

      def store(frame, amount)
        @park.consume(frame, amount)
      end

      def consumer?
        true
      end

      def excess_constrained?
        true
      end

      def path_class
        Heat::TechnologyPath
      end
    end # Consumer
  end # Heat
end
