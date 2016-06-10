module Network
  module Heat
    # Triggers buffering of excess production park energy.
    class Buffer < Technologies::Generic
      Installed = Struct.new(:type)

      def initialize(park)
        @park      = park
        @load      = []
        @installed = Installed.new(:heat_buffer)
      end

      def production_at(frame)
        0.0
      end

      def mandatory_consumption_at(frame)
        0.0
      end

      def conditional_consumption_at(frame)
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

