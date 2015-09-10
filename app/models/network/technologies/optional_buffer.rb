module Network
  module Technologies
    # OptionalBuffers are a hybrid consumption/storage technology. A profile is
    # used to define the energy consumed, but it may also store excess energy
    # from the network for later use.
    #
    # If the buffer has insufficient energy stored to meet the demand defined by
    # the profile, the deficit goes unmet. Buffers do not take energy from the
    # grid. Energy stored in the buffer may only be used to satisfy its own
    # consumption, and is not released back to the network.
    class OptionalBuffer < Buffer
      def self.disabled?(options)
        ! options[:solar_power_to_heat]
      end

      def self.disabled_class
        Null
      end

      def self.build(installed, profile, **options)
        super(installed, profile, **options.merge(additional_profile: profile))
      end

      # Public: Buffers may not return their stored energy back to the network.
      # Therefore, their consumption equals their output in order that the two
      # balance out to zero.
      #
      # As the buffer is "optional", it only receives "conditional" loads when
      # there is available excess within the network. The availability profile
      # required by the Buffer superclass is therefore ignored.
      #
      # Returns a numeric.
      def mandatory_consumption_at(frame)
        production_at(frame)
      end
    end # OptionalBuffer
  end
end
