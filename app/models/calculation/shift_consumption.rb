module Calculation
  class ShiftConsumption
    include Singleton

    def shift_consumption(frame, path)
      @congestions ||= {}
      @frame       = frame
      @path        = path

      resolve_congestions
      set_congestions
    end

    private

    # If there's space on the network or if the path is at the 12th/last frame

    def resolve_congestions
      @congestions.each_pair do |max_delay, exceedance|
        if !@path.congested_at?(@frame, exceedance) || @frame == max_delay
          @path.consume(@frame, exceedance)
          @congestions.delete(max_delay)
        end
      end
    end

    def set_congestions
      if is_flexible?
        exceedance = @path.technology.profile.at(@frame)
        @congestions[max_congestion_delay] = exceedance
        @path.consume(@frame, -exceedance)
      end
    end

    def is_flexible?
      @path.congested_at?(@frame) &&
      @path.technology.is_a?(Network::Technologies::DeferrableConsumer)
    end

    def max_congestion_delay
      profile_size < max_frame ? profile_size : max_frame
    end

    def max_frame
      @frame + 12
    end

    def profile_size
      @path.technology.profile.size - 1
    end
  end
end
