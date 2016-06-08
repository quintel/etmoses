module Network
  module Heat
    # Triggers buffering of excess production park energy.
    class Buffer < Technologies::Generic
      def initialize(park)
        @park = park
        @load = []
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

      def store(frame, _amount)
        @load[frame] ||= @park.reserve_excess!(frame)
      end
    end # Buffer
  end # Heat
end # Network

