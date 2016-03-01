module Network
  module Technologies
    # Stores and wraps technologies whose profile and storage reserve is shared
    # between them.
    class Composite
      attr_reader :volume, :techs, :reserve

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
      # Returns an array of Composite:Wrappers.
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

      # Wraps technologies which are part of a component to ensure that the
      # depleting profile is correctly adjusted for received energy.
      #
      # The delegator is based on Buffer, since it is the most complex of the
      # technologies modelled. This is not particularly future-proof: if another
      # technology is added with public methods not defined by Buffer, the
      # delegation will not work correctly (raising a NoMethodError).
      class Wrapper < FastDelegator.create(Buffer)
        def initialize(obj, composite)
          super(obj)
          @composite = composite
          @handle_decay = obj.respond_to?(:stored)
        end

        def production_at(frame)
          # Force evaluation of buffer decay.
          stored.at(frame) if @handle_decay
          super
        end

        def store(frame, amount)
          super
          profile.deplete(frame, amount)
        end

        def receive_mandatory(frame, amount)
          super
          profile.deplete(frame, amount)
        end

        # Public: Returns if the technology is a buffering technology. If false,
        # it is "boosting".
        #
        # Returns true or false.
        def buffering?
          false
        end

        def inspect
          "#<#{ self.class.name } #{ __getobj__.inspect }>"
        end
      end # Wrapper

      class BufferingWrapper < Wrapper
        def store(frame, amount)
          super
          @composite.input(frame, amount)
        end

        def receive_mandatory(frame, amount)
          super
          @composite.input(frame, amount)
        end

        def mandatory_consumption_at(frame)
          constrain(frame, super)
        end

        def conditional_consumption_at(frame)
          constrain(frame, super)
        end

        def buffering?
          true
        end

        private

        def constrain(frame, amount)
          margin = @composite.consumption_margin_at(frame)
          amount < margin ? amount : margin
        end
      end

      class BoostingWrapper < Wrapper
        def mandatory_consumption_at(frame)
          @composite.boosting_enabled_at?(frame) ? super : 0.0
        end

        def conditional_consumption_at(frame)
          # Boosting technologies will never draw extra energy to fill up the
          # buffer; they satisfy whatever amount is needed to "boost" production
          # to meet demand and nothing more.
          0.0
        end
      end

      # All HHP consumption is (currently) classed as conditional, therefore we
      # expect a non-zero load when boosting HHP consumption occurs.
      class HHPBoostingWrapper < Wrapper
        def mandatory_consumption_at(frame)
          0.0
        end

        def conditional_consumption_at(frame)
          @composite.boosting_enabled_at?(frame) ? super : 0.0
        end
      end
    end # Composite
  end
end
