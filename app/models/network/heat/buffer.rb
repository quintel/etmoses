module Network
  module Heat
    # Triggers buffering of excess production park energy.
    class Buffer < Technologies::Generic
      Installed = Struct.new(:type)

      attr_reader :reserves

      def initialize(park, reserves)
        @park      = park
        @reserves  = reserves
        @load      = []
        @installed = Installed.new(:heat_buffer)
      end

      def label
        'heat_network_buffer'.freeze
      end

      def net_load
        reserves.map { |reserve| Network::Curve.from(reserve.load) }.reduce(:+)
      end

      def production_at(_frame)
        0.0
      end

      def mandatory_consumption_at(_frame)
        0.0
      end

      def conditional_consumption_at(_frame, _path)
        0.0
      end

      def load_at(frame)
        @load[frame] || 0.0
      end

      def receive_mandatory(frame, _amount)
        @load[frame] ||= @park.reserve_excess_at!(frame)
      end
    end # Buffer
  end # Heat
end # Network
