module Network
  module Technologies
    # Consumes excess energy from the testing ground, with the profile defining
    # the maximum amount which may be consumed. If there is no excess, the
    # Siphon will be turned off and will receive nothing.
    class Siphon < Generic
      extend Disableable

      attr_accessor :output_path

      def self.disabled?(options)
        !options[:solar_power_to_gas]
      end

      def load_at(frame)
        conditional_consumption_at(frame)
      end

      def mandatory_consumption_at(_frame)
        0.0
      end

      def conditional_consumption_at(frame)
        @profile.at(frame)
      end

      def excess_constrained?
        true
      end

      def store(frame, amount)
        # Energy consumed by the Siphon is converted into production on the
        # assigned output path.
        if output_path && amount > 0
          output_path.consume(frame, -amount)
        end
      end

      # Internal: A Siphon-only feature. Consumption will be converted to
      # production on the named network.
      def output_carrier
        :gas
      end
    end # Siphon
  end
end
