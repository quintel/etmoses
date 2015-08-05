module Network
  module Technologies
    # A technology which will run, provided there is sufficient capacity in the
    # network, otherwise the load is discarded without being satisfied.
    #
    # "I don't need to run my heater, I'll wear another layer of clothes..."
    class OptionalConsumer < Generic
      extend Disableable

      def self.disabled_class
        Generic
      end

      def self.disabled?(options)
        !options[:saving_base_load]
      end

      def conditional_consumption_at(_frame)
        load_at(_frame)
      end

      def mandatory_consumption_at(_frame)
        0.0
      end

      def capacity_constrained?
        true
      end

      def store(_frame, _amount)
      end
    end # OptionalConsumer
  end
end
