module Network
  module Technologies
    # A buffer whose conditional consumption (buffering) may be limited by the
    # network capacity.
    class HeatPump < Buffer
      def self.disabled?(_options)
        false
      end

      def self.disabled_class
        self
      end

      def initialize(installed, profile,
                     hp_capacity_constrained: false,
                     solar_power_to_heat: false,
                     **)
        super

        @capacity_constrained = hp_capacity_constrained
        @high_energy = solar_power_to_heat
      end

      # Public: Sets the Reserve used to store energy.
      #
      # In the event that a low-energy amplified reserve is given, a copy of the
      # high-energy version is retained so that the heat-pump may buffer excess
      # local energy into the high-energy reserve when "solar_power_to_heat" is
      # enabled.
      #
      # Returns the Reserve.
      def stored=(reserve)
        if @high_energy && reserve.respond_to?(:high_energy)
          super(reserve.high_energy)
        else
          super
        end

        @low_reserve = reserve
      end

      # Public: Determines how much extra energy the HeatPump may consume. This
      # energy will be stored in the reserve for future consumption.
      #
      # When "solar_power_to_heat" is enabled, the heat pump may consume excess
      # local energy into the high-energy reserve. When no excess energy is
      # available, energy from the grid may be used to buffer, but only up to
      # the low-energy reserve volume.
      #
      # Returns a numeric.
      def conditional_consumption_at(frame, path)
        return super unless @high_energy

        excess     = path.excess_at(frame)
        low_energy = @low_reserve.unfilled_at(frame)

        wanted =
          if excess > 0 && excess > low_energy
            # Available excess exceeds the volume of the low-energy reserve. We
            # may therefore buffer the excess up to the high-energy volume.
            high_energy = @stored.unfilled_at(frame)

            (excess < high_energy ? excess : high_energy) /
              @installed.performance_coefficient
          else
            low_energy / @installed.performance_coefficient
          end

        wanted += @receipts.conditional[frame]

        @capacity.limit_conditional(frame, wanted)
      end

      # Heat pumps, unlike other buffering technologies, may take energy from
      # the grid when buffering.
      def excess_constrained?
        false
      end

      def capacity_constrained?
        @capacity_constrained
      end
    end # HeatPump
  end
end
