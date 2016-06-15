module Network
  module Technologies
    module Composite
      # Stores and wraps technologies whose profile and storage reserve is shared
      # between them.
      class Manager
        attr_reader :volume, :techs, :reserve, :demand

        def initialize(capacity, volume, profile)
          @techs    = []

          @capacity = capacity
          @demand   = profile
          @profile  = DepletingCurve.new(profile)
          @inputs   = DefaultArray.new { 0.0 }

          @volume = (volume || 0.0) * profile.frames_per_hour

          @reserve = Reserve.new(@volume) do |frame, amount|
            wanted = @profile.at(frame)
            decay  = wanted < amount ? wanted : amount

            # If a capacity is defined, the reserve may deplete no more than the
            # capacity of the composite permits.
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

        # Public: Informs the composite that an amount of energy has been received
        # which contributes to the consumption of the device.
        #
        # An input is energy delivered to to the composite using a buffering
        # technology; boostinh techs are not onstrained by the capacity of the
        # composite, and therefore their consumption is not included.
        #
        # Returns the total input in the current frame.
        def input(frame, amount)
          @inputs[frame] += amount
        end

        # Public: Determines how much more buffering energy may be input to the
        # composite before it runs out of capacity.
        #
        # Returns a numeric.
        def consumption_margin_at(frame)
          margin = @capacity - @inputs[frame]
          margin > 0 ? margin : 0.0
        end

        # Public: Determines if boosting technologies are permitted (or required)
        # to run in the given frame.
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
          wrapped =
            if tech.installed.position_relative_to_buffer == 'boosting'.freeze
              if tech.is_a?(HHP::Base)
                # Hack :(
                HHPBoostingWrapper.new(tech, self)
              else
                BoostingWrapper.new(tech, self)
              end
            else
              BufferingWrapper.new(tech, self)
            end

          @techs.push(wrapped)

          wrapped.profile = @profile
          wrapped.stored = @reserve if tech.respond_to?(:stored)
          wrapped.volume = @volume / (tech.installed.performance_coefficient || 1)

          wrapped
        end
      end # Manager
    end # Composite
  end
end
