module Network
  module Technologies
    # Stores and wraps technologies whose profile and storage reserve is shared
    # between them.
    class Composite
      attr_reader :techs

      def initialize(volume, profile)
        @techs   = []
        @profile = profile

        volume = volume * profile.frames_per_hour

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

      # Public: Adds a new technology to the composite.
      #
      # Returns the wrapped technology.
      def add(tech)
        wrapped = Wrapper.new(tech)

        @techs.push(wrapped)

        wrapped.profile = @profile
        wrapped.stored  = @reserve if tech.respond_to?(:stored)

        wrapped
      end

      # Wraps technologies which are part of a component to ensure that the
      # depleting profile is correctly adjusted for received energy.
      class Wrapper < SimpleDelegator
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
    end # Composite
  end
end
