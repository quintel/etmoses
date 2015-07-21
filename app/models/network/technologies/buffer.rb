module Network
  module Technologies
    # Buffers are a hybrid load-management/storage feature which will apply a
    # load to the network in times when there is available capacity. The energy
    # provided is stored in the buffer until it is needed by the technology.
    #
    # The principle is to load the network in times of available capacity in
    # hope of avoiding exceedances later.
    class Buffer < Storage
      def self.disabled?(options)
        !options[:buffering_heat_pumps]
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

      def production_at(frame)
        prod = super - @profile.at(frame)
        prod < 0 ? 0.0 : prod
      end

      # Public: The mandatory consumption of a pre-emptive consumer may be
      # reduced by the amount currently stored within the technology (from a
      # period when there was no excess).
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

      def consumer?
        true
      end

      def capacity_constrained?
        true
      end

      def excess_constrained?
        false
      end

      # Public: Defines how much energy may be stored by the consumer without
      # the need to consume. Arbitrarily chosen to be four times the capacity.
      def volume
        capacity * 4
      end
    end # Buffer
  end
end
