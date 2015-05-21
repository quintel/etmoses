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
    # Public: The amount of energy to be retained in the buffer at the end of
    # the frame must decrease by the amount consumed (defined in the profile).
    def production_at(frame)
      prod = super - @profile.at(frame)
      prod < 0 ? 0.0 : prod
    end

    # Public: Buffers may not return their stored energy back to the network.
    # Therefore, their consumption equals their output in order that the two
    # balance out to zero
    def mandatory_consumption_at(frame)
      production_at(frame)
    end
  end # Buffer
end # Network
