module Network
  module Technologies
    # Stores and wraps technologies whose profile and storage reserve is shared
    # between them.
    class Composite
      attr_reader :volume, :techs

      def initialize(capacity, volume, profile)
        @techs    = []

        @capacity = capacity
        @demand   = profile
        @profile  = DepletingCurve.new(profile)

        volume = (volume || 0.0) * profile.frames_per_hour

        @reserve = Reserve.new(volume) do |frame, amount|
          wanted = @profile.at(frame)
          decay  = wanted < amount ? wanted : amount

          # Have to adjust the profile to reflect energy provided by the
          # Reserve.
          @profile.deplete(frame, decay)

          decay
        end

        techs.each { |tech| add(tech) }
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
        (@reserve.at(frame).zero? && @profile.at(frame) > 0) ||
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
            BoostingWrapper.new(tech, self)
          else
            Wrapper.new(tech, self)
          end

        @techs.push(wrapped)

        wrapped.profile = @profile
        wrapped.stored  = @reserve if tech.respond_to?(:stored)

        wrapped
      end

      # Wraps technologies which are part of a component to ensure that the
      # depleting profile is correctly adjusted for received energy.
      class Wrapper < SimpleDelegator
        def initialize(obj, composite)
          super(obj)
          @composite = composite
        end

        def store(frame, amount)
          super
          profile.deplete(frame, amount)
        end

        def receive_mandatory(frame, amount)
          profile.deplete(frame, amount)
        end

        def inspect
          "#<#{ self.class.name } #{ __getobj__.inspect }>"
        end
      end # Wrapper

      class BoostingWrapper < Wrapper
        def mandatory_consumption_at(frame)
          @composite.boosting_enabled_at?(frame) ? super : 0.0
        end

        def conditional_consumption_at(frame)
          # Boosting technologies will never draw extra energy to fill up the
          # buffer; the satisfy whatever amount is needed to "boost" production
          # to meet demand and nothing more.
          0.0
        end
      end
    end # Composite
  end
end
