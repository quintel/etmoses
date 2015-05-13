module Network
  # Buffers are a hybrid consumption/storage technology. A profile is used to
  # define the energy consumed, but it may also store excess energy from the
  # network for later use.
  #
  # If the buffer has insufficient energy stored to meet the demand defined by
  # the profile, the deficit goes unmet. Buffers do not take energy from the
  # grid. Energy stored in the buffer may only be used to satisfy its own
  # consumption, and is not released back to the network.
  class Buffer < Storage
    # Public: The energy stored in the buffer after computing each frame.
    #
    # Returns a DefaultArray.
    def stored
      @stored ||= DefaultArray.new do |frame|
        remaining = mandatory_consumption_at(frame) - @profile.at(frame)
        remaining < 0 ? 0.0 : remaining
      end
    end

    # Public: Buffers may not return their stored energy back to the network.
    # Therefore, their consumption equals their output in order that the two
    # balance out to zero
    def mandatory_consumption_at(frame)
      production_at(frame)
    end

    # Public: Theoretically, given no input capacity, a buffer may satisfy its
    # own internal demand -- and store up to its full capacity -- in the same
    # frame. It therefore requests the full amount needed to fill its unmet
    # storage capacity, and whatever it will consume.
    def conditional_consumption_at(frame)
      super + @profile.at(frame)
    end
  end # Buffer
end # Network
