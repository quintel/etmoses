module Network
  module Technologies
    class LegacyBuffer < Storage
      def self.build(installed, profile, options)
        unless options[:additional_profile]
          fail "Missing use profile for #{ installed.name }"
        end

        super
      end

      def self.disabled_profile(profile, options)
        Network::Curve.from(super) + options[:additional_profile]
      end

      def self.disabled?(options)
        false
      end

      def initialize(installed, profile,
                     hp_capacity_constrained: false,
                     additional_profile:, **)
        super

        @use_profile          = additional_profile
        @capacity_constrained = hp_capacity_constrained
      end

      # Keep the original production_at which tells us how much energy is stored
      # and available for use.
      alias_method :available_storage_at, :production_at

      # Public: Production describes the amount stored in the buffer at the
      # start of the frame, minus that consumed by the use profile. If use
      # exceeds the amount stored, the deficit goes unmet.
      #
      # Returns a numeric.
      def production_at(frame)
        prod = super - (@use_profile.at(frame) * @use_profile.frames_per_hour)
        prod < 0 ? 0.0 : prod
      end

      # Public: The minimum amount of energy required to fulfil the needs of the
      # buffer in this time step. This minimum is defined by the availability
      # profile which specifies how full the buffer should be at the end of the
      # frame.
      #
      # Returns a numeric.
      def mandatory_consumption_at(frame)
        required = @profile.at(frame) * @profile.frames_per_hour
        stored   = production_at(frame)

        # When storage mode is turned off, the EV is not allowed to
        # discharge energy for use in other technologies; it is exclusively
        # for its own use.
        required = stored if stored > required

        @capacity.limit_mandatory(frame, required)
      end

      # Public: EVs should not overload the network.
      def capacity_constrained?
        @capacity_constrained
      end

      # Public: EV conditional load may come from the grid.
      def excess_constrained?
        false
      end
    end # LegacyBuffer
  end
end
