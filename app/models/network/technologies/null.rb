module Network
  module Technologies
    # A technology which does absolutely nothing. Nil. Nada.
    class Null < Generic
      def load_at(_frame)
        0.0
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
    end # Null
  end
end
