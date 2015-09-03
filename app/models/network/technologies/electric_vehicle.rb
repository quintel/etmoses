module Network
  module Technologies
    # Implements an ElectricVehicle whose profile describes the minimum amount
    # of energy which must be stored in the technology in any given frame.
    #
    # A negative value in the curve indicates that the vehicle is disconnected
    # and may not supply or consume any energy until reconnected. An
    # ElectricVehicle reconnects with zero energy stored.
    class ElectricVehicle < Storage
      def initialize(installed, profile,
                     buffering_electric_car: true,
                     solar_storage: false, **)
        super

        @storage       = solar_storage
        @buffering     = buffering_electric_car
        @recent_excess = 0.0
      end

      def self.disabled?(options)
        !options[:solar_storage] && !options[:buffering_electric_car]
      end

      # Internal:  With storage disabled, a car should consume energy from the
      # network as and when needed, without storing excesses for later use.
      def self.disabled_class
        Generic
      end

      # Internal: EV profiles describe the minimum amount of load to be stored
      # in each frame. Convert the profile to show the relative change over
      # time, which will give us the per-frame load of the vehicle.
      def self.disabled_profile(profile)
        profile = profile.to_a
        to_kw   = profile.length.to_f / 8760.0
        first   = profile[0] < 0 ? 0.0 : profile[0]

        [first * to_kw, *(profile.each_cons(2).map do |previous, now|
          if now < 0
            0.0
          elsif previous < 0
            now * to_kw
          else
            (now - previous) * to_kw
          end
        end)]
      end

      def production_at(frame)
        disconnected?(frame) ? disconnected_load_at(frame) : super
      end

      # Public: The minimum amount of energy required to fulfil the needs of the
      # vehicle in this time step.
      #
      # Returns a numeric.
      def mandatory_consumption_at(frame)
        if disconnected?(frame)
          disconnected_load_at(frame)
        else
          required = required_at(frame)
          stored   = production_at(frame)

          # When storage mode is turned off, the EV is not allowed to
          # discharge energy for use in other technologies; it is exclusively
          # for its own use.
          required = stored if ! @storage && stored > required

          @capacity.limit_mandatory(frame, required)
        end
      end

      # Public: Describes the unfilled storage capacity which may be assigned
      # from excess production in the network.
      #
      # Returns a numeric.
      def conditional_consumption_at(frame)
        disconnected?(frame) ? 0.0 : super
      end

      # Public: EVs should not overload the network.
      def capacity_constrained?
        true
      end

      # Public: EV conditional load may come from the grid.
      def excess_constrained?
        ! @buffering
      end

      private

      def disconnected?(frame)
        profile && profile.at(frame) < 0
      end

      def disconnected_load_at(frame)
        if frame.zero?
          @recent_excess = 0.0
        elsif disconnected?(frame - 1)
          @recent_excess
        else
          # The EV was connected to the network in the previous frame; we need
          # to check if it had an excess of energy stored (beyond that required
          # by the profile) and ensure this energy persists while disconnected.
          @recent_excess = stored[frame - 1] - required_at(frame - 1)
        end
      end

      def required_at(frame)
        @profile.at(frame) * @profile.frames_per_hour
      end
    end # ElectricVehicle
  end
end
