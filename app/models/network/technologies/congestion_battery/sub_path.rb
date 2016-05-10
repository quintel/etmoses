module Network::Technologies
  module CongestionBattery
    class SubPath < Network::SubPath
      # The subpath which includes the parent of the node containing the
      # congestion battery. We will try to solve congestion problems on that
      # path
      attr_accessor :solver_path

      def mandatory_consumption_at(frame)
        amount =
          @technology.mandatory_consumption_at(frame) -
          receipts.mandatory[frame]

        amount <= 0 ? 0.0 : amount
      end

      def conditional_consumption_at(frame)
        amount    = @technology.conditional_consumption_at(frame, solver_path)
        available = @full_path.consumption_margin_at(frame)

        amount < available ? amount : available
      end

      def consume(frame, amount, conditional = false)
        return if amount < 1e-10

        excess = excess_at(frame)

        if amount > excess
          # Consume using the full path however much is not available as
          # excess; this energy is coming from the HV network.
          @full_path.full_sub_path.consume(frame, amount - excess, conditional)
          super(frame, excess, conditional)
        else
          super
        end
      end

      # Public: The distance from the end of the subpath to the head node.
      # Forced to -1 to ensure the path is computed last.
      def distance
        -1
      end
    end
  end # CongestionBattery
end # Network::Technologies
