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

      alias orig_mandatory_consumption_at mandatory_consumption_at

      def conditional_consumption_at(frame, _path)
        orig_mandatory_consumption_at(frame)
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
