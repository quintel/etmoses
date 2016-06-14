module Network
  module Heat
    # Describes the central producers available within a testing ground.
    #
    # Contains zero or more "must run" producers whose production is dictated by
    # a profile, and are always running. Excess energy from must run producers
    # will be stored in an internal reserve, for later use.
    #
    # "Dispatchable" production runs only if demand exceeds the energy which can
    # be emitted from the reserve and produced by the must runs.
    class ProductionPark
      # Public: Creates a new production park
      #
      # must_run         - An enumerable containing zero or more must run
      #                    Heat::Producer instances.
      # dispatchable     - An enumerable containing zero or more must-run
      #                    Heat::Producer instances.
      # volume           - A volume describing how much excess energy may be
      #                    stored from must-run and dispatchable technologies.
      # amplified_volume - An optional higher volume which may store excess
      #                    energy from must-run technologies.
      #
      # Returns a ProductionPark.
      def initialize(must_run:, dispatchable:, volume:, amplified_volume: volume)
        @volume            = Types::Volume[volume]
        @amplified_volume  = Types::Volume[amplified_volume]

        if @amplified_volume < @volume
          fail "Amplified volume (#{ @amplified_volume.inspect }) must be " \
               "equal to or greater than the volume (#{ @volume.inspect })"
        end

        @must_run          = Array(must_run)
        @dispatchable      = Array(dispatchable)

        @reserve           = Reserve.new(volume)
        @amplified_reserve = Reserve.new(amplified_volume - volume)
      end

      def create_consumer(installed)
        Consumer.new(installed, installed.profile)
      end

      # Public: Returns a Buffer technology which will be used within the
      # network calculation to instruct the production park to reserve excess
      # heat energy.
      #
      # Returns a Heat::Buffer.
      def buffer_tech
        @buffer_tech ||= Buffer.new(self)
      end

      # Public: Informs the park that an `amount` of energy has been used by a
      # Consumer.
      #
      # If the `amount` is greater than the available production, all production
      # will be used, and buffers emptied, but no error raised. If necessary,
      # check the the return value equals the `amount` to assert that all the
      # consumption was satisfied.
      #
      # Returns the amount of energy which was provided by the production park.
      def consume(frame, amount)
        return 0.0 if amount.zero?

        original = amount

        @must_run.each do |tech|
          amount -= tech.take(frame, amount)
        end

        amount -= @amplified_reserve.take(frame, amount)
        amount -= @reserve.take(frame, amount)

        @dispatchable.each do |tech|
          amount -= tech.take(frame, amount)
        end

        original - amount
      end

      # Public: Determines how much energy can be provided by the park in the
      # chosen `frame`. Accounts for energy stored in buffers and all
      # production.
      #
      # Returns a numeric.
      def available_production_at(frame)
        reserved_at(frame) +
          @must_run.sum { |d| d.available_production_at(frame) } +
          @dispatchable.sum { |d| d.available_production_at(frame) }
      end

      # Public: Returns the amount of energy stored in the buffer in the given
      # `frame`.
      def reserved_at(frame)
        @reserve.at(frame) + @amplified_reserve.at(frame)
      end

      # Internal: Given a technology, stores its excess production in the
      # buffers for later use.
      #
      # Returns the amount of energy stored.
      def reserve_excess_at!(frame)
        @must_run.sum { |tech| reserve_excess(frame, tech) } +
          @dispatchable.sum { |tech| reserve_excess(frame, tech) }
      end

      # Internal: Given a technology, stores its excess production in the
      # buffers for later use.
      #
      # Returns the amount of energy stored.
      private def reserve_excess(frame, tech)
        original = excess = tech.available_production_at(frame)

        excess -= tech.take(frame, @reserve.add(frame, excess))

        if excess > 0 && tech.must_run?
          excess -= tech.take(frame, @amplified_reserve.add(frame, excess))
        end

        original - excess
      end
    end # ProductionPark
  end # Heat
end
