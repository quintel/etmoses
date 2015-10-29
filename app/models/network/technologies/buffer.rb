module Network
  module Technologies
    class Buffer < Storage
      def self.disabled?(options)
        ! options[:buffering_space_heating]
      end

      def self.disabled_class
        Generic
      end

      def stored
        @stored ||= DefaultArray.new(&method(:production_at))
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
        prod = super - @profile.at(frame)
        prod < 0 ? 0.0 : prod
      end

      # Public: The minimum amount of energy required to fulfil the needs of the
      # buffer in this time step. This minimum is defined by the availability
      # profile which specifies how full the buffer should be at the end of the
      # frame.
      #
      # Returns a numeric.
      def mandatory_consumption_at(frame)
        production = production_at(frame)
        required   = @profile.at(frame)

        if production.zero? && required > 0
          stored   = available_storage_at(frame)
          unfilled = required - stored

          unfilled > 0 ? unfilled : 0.0
        else
          production
        end
      end

      # Public: EVs should not overload the network.
      def capacity_constrained?
        true
      end

      # Public: EV conditional load may come from the grid.
      def excess_constrained?
        false
      end
    end # Buffer
  end
end
