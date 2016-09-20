module Network
  module Technologies
    module Composite
      # Members of composites which have no buffering behavior
      class Consumer < Generic
        def self.from(other)
          new(other.installed, other.profile)
        end

        def initialize(*)
          super

          @receipts = Receipts.new
          @capacity = CapacityLimit.new(self)
        end

        def mandatory_consumption_at(frame)
          # See Buffer#mandatory_consumption_at for an explanation of receipts.
          @capacity.limit_mandatory(frame, super + @receipts.mandatory[frame])
        end

        def conditional_consumption_at(*)
          0.0
        end

        def receive_mandatory(frame, amount)
          super
          @receipts.mandatory[frame] += amount
        end
      end # Consumer
    end # Composite
  end
end
