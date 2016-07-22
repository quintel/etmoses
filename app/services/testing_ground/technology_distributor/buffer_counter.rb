class TestingGround
  class TechnologyDistributor
    class BufferCounter
      def add(type)
        counter[type] += 1
      end

      def get(type)
        counter[type]
      end

      private

      def counter
        @buffer_counter ||= Hash.new { |k,v| k = -1 }
      end
    end
  end
end
