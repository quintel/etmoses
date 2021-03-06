module Network
  module Technologies
    module Composite
      # Stores and wraps technologies whose profile and storage reserve is
      # shared between them.
      class Manager
        attr_reader :volume, :techs, :reserve, :demand

        def initialize(capacity, volume, profile)
          @techs    = []

          @capacity = capacity
          @demand   = profile
          @profile  = DepletingCurve.new(profile)
          @inputs   = DefaultArray.new { 0.0 }
          @volume   = Types::Volume[(volume || 0.0)] * profile.frames_per_hour

          @reserve =
            AmplifiedReserve.new(@volume, @volume * 1.78) do |frame, amount|
              wanted = @profile.at(frame)
              decay  = wanted < amount ? wanted : amount

              # If a capacity is defined, the reserve may deplete no more than
              # the capacity of the composite permits.
              decay = @capacity if @capacity && decay > @capacity

              # Have to adjust the profile to reflect energy provided by the
              # Reserve.
              @profile.deplete(frame, decay)

              decay
            end
        end

        # Public: All the technologies which are contained in the composite.
        # Buffers first.
        #
        # Returns an array of Composite::Wrappers.
        def techs
          @techs.partition(&:buffering?).flatten
        end

        # Public: Informs the composite that an amount of energy has been
        # received which contributes to the consumption of the device.
        #
        # An input is energy delivered to to the composite using a buffering
        # technology; boosting techs are not constrained by the capacity of the
        # composite, and therefore their consumption is not included.
        #
        # Returns the total input in the current frame.
        def input(frame, amount)
          @inputs[frame] += amount
          amount
        end

        # Public: Determines how much more buffering energy may be input to the
        # composite before it runs out of capacity.
        #
        # Returns a numeric.
        def consumption_margin_at(frame)
          margin = @capacity - @inputs[frame]
          margin > 0 ? margin : 0.0
        end

        # Public: Determines if boosting technologies are permitted (or
        # required) to run in the given frame.
        #
        # Boosting technologies will activate in order to make up a deficit in
        # production in order to meet a spike in demand.
        #
        # Returns true or false.
        def boosting_enabled_at?(frame)
          # If there was insufficient energy in the reserve to satisfy demand,
          # boosting technologies may be enabled.
          @profile.at(frame) > 0 ||
            # If more energy is demanded than the buffer has capacity, boosting
            # technologies are enabled.
            (@demand.at(frame) > @capacity)
        end

        # Public: Adds a new technology to the composite.
        #
        # Returns the wrapped technology.
        def add(tech)
          # Convert generic technologies to those which can correct for the
          # depleting profile curve.
          tech = Consumer.from(tech) if tech.class == Generic

          wrapped = wrapper_class_for(tech).new(tech, self)
          wrapped.profile = @profile

          if tech.respond_to?(:stored)
            # Technologies which consume only excess local electricity when
            # buffering may use the high-energy mode in the reserve. Those which
            # take energy from the grid may not.
            wrapped.stored =
              tech.excess_constrained? ? @reserve.high_energy : @reserve

            wrapped.volume = wrapped.stored.volume / (
              tech.installed.performance_coefficient || 1
            )
          end

          @techs.push(wrapped)

          wrapped
        end

        # Internal: Determines the correct wrapper class for the given
        # technology
        #
        # Returns a Composite::Wrapper class.
        private def wrapper_class_for(tech)
          if tech.installed.position_relative_to_buffer == 'boosting'.freeze
            tech.is_a?(HHP::Base) ? HHPBoostingWrapper : BoostingWrapper
          else
            BufferingWrapper
          end
        end
      end # Manager
    end # Composite
  end
end
