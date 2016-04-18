module Network
  module Chain
    class Source
      def initialize(profile:, capacity: Float::INFINITY)
        @capacity = Types::Capacity[capacity]
        @profile  = profile
        @load     = []
      end

      def call(frame)
        @load[frame] ||= begin
          amount = @profile.at(frame) || 0.0

          if amount < 0
            amount > -@capacity ? amount : -@capacity
          else
            amount = amount < @capacity ? amount : @capacity
            @profile.deplete(frame, amount) if @profile.respond_to?(:deplete)

            amount
          end
        end
      end
    end # Source
  end # Chain
end
